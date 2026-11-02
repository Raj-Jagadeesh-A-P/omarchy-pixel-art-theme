#!/bin/bash

# install.sh
# Run once after `omarchy theme install <url>` to:
#   1. Install the bundled Pixora icon pack
#   2. Install the pixel-art top bar (pill bar, arch menu, shell config)
#   3. Create a theme-set.d hook so icons persist on every theme switch
#
# Omarchy 4+ (Quattro). The shell, bar, launcher, notifications and lock
# screen are themed automatically from colors.toml — no extra setup needed.
#
# Usage:
#   bash ~/.config/omarchy/themes/pixel-art/install.sh
#   bash ~/.config/omarchy/themes/pixel-art/install.sh --no-bar

set -e

THEME_NAME="pixel-art"
SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "$0")")" && pwd)"
THEME_DIR="$HOME/.config/omarchy/themes/$THEME_NAME"
CURRENT_THEME_DIR="$HOME/.local/state/omarchy/current/theme"
CONFIG_DIR="$HOME/.config/omarchy"
HOOK_FILE="$CONFIG_DIR/hooks/theme-set.d/$THEME_NAME-icons.sh"
LEGACY_HOOK="$CONFIG_DIR/hooks/theme-set"
ICON_DST="$HOME/.local/share/icons"
STAMP="$(date +%Y%m%d%H%M%S)"

WITH_BAR=1
for arg in "$@"; do
  if [[ $arg == "--no-bar" ]]; then
    WITH_BAR=0
  fi
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
backup_if_changed() {
  local src="$1" dst="$2"

  [[ -e $dst || -L $dst ]] || return 0
  cmp -s -- "$src" "$dst" && return 0
  cp -a -- "$dst" "$dst.bak.$STAMP"
  echo "  backed up ${dst##*/} → ${dst##*/}.bak.$STAMP"
}

# Replace a destination safely: existing symlinks are removed, while a real
# directory from a manual install is moved aside instead of destroyed.
install_icon_link() {
  local src="$1" dst="$2"

  if [[ -L $dst ]]; then
    rm -f -- "$dst"
  elif [[ -e $dst ]]; then
    mv -- "$dst" "$dst.bak.$STAMP"
    echo "  backed up ${dst##*/} → ${dst##*/}.bak.$STAMP"
  fi

  ln -s -- "$src" "$dst"
}

# ---------------------------------------------------------------------------
# 1. Install Pixora icon themes
# ---------------------------------------------------------------------------
echo ":: Installing Pixora icon themes → $ICON_DST"

# Prefer the git clone over the staged copy. Omarchy's theme staging skips
# symlinks from cloned themes, and this pack keeps ~1049 icon aliases plus
# pixelitos-light/128 as symlinks — linking to the staged tree drops them.
ICONS_SRC="$THEME_DIR/icons/pixora-icons"
[[ -d $ICONS_SRC ]] || ICONS_SRC="$SCRIPT_DIR/icons/pixora-icons"
[[ -d $ICONS_SRC ]] || ICONS_SRC="$CURRENT_THEME_DIR/icons/pixora-icons"

if [[ -d $ICONS_SRC ]]; then
  mkdir -p "$ICON_DST"
  install_icon_link "$ICONS_SRC/pixelitos-dark"  "$ICON_DST/pixelitos-dark"
  install_icon_link "$ICONS_SRC/pixelitos-light" "$ICON_DST/pixelitos-light"
  install_icon_link "$ICONS_SRC/icons"           "$ICON_DST/pixora"

  gtk-update-icon-cache "$ICON_DST/pixora"          2>/dev/null || true
  gtk-update-icon-cache "$ICON_DST/pixelitos-dark"  2>/dev/null || true
  gtk-update-icon-cache "$ICON_DST/pixelitos-light" 2>/dev/null || true
  echo "✓ Icon themes installed: pixora, pixelitos-dark, pixelitos-light"
else
  echo "! Bundled icons not found (looked in $THEME_DIR, $SCRIPT_DIR and $CURRENT_THEME_DIR)" >&2
fi

# ---------------------------------------------------------------------------
# 2. Install the pixel-art top bar
# ---------------------------------------------------------------------------
if (( WITH_BAR )); then
  BAR_SRC="$SCRIPT_DIR/bar"

  if [[ -d $BAR_SRC ]]; then
    echo ":: Installing pixel-art top bar → $CONFIG_DIR"

    mkdir -p "$CONFIG_DIR/bar/modules" "$CONFIG_DIR/plugins"

    backup_if_changed "$BAR_SRC/shell.json" "$CONFIG_DIR/shell.json"
    backup_if_changed "$BAR_SRC/shell.toml" "$CONFIG_DIR/shell.toml"
    backup_if_changed "$BAR_SRC/modules/arch-menu.qml" "$CONFIG_DIR/bar/modules/arch-menu.qml"

    if [[ -d $CONFIG_DIR/plugins/user.pill-bar ]] &&
       ! diff -rq -- "$BAR_SRC/plugins/user.pill-bar" "$CONFIG_DIR/plugins/user.pill-bar" >/dev/null 2>&1; then
      rm -rf -- "$CONFIG_DIR/plugins/user.pill-bar.bak.$STAMP"
      mv -- "$CONFIG_DIR/plugins/user.pill-bar" "$CONFIG_DIR/plugins/user.pill-bar.bak.$STAMP"
      echo "  backed up user.pill-bar → user.pill-bar.bak.$STAMP"
    fi

    cp -- "$BAR_SRC/shell.json" "$CONFIG_DIR/shell.json"
    cp -- "$BAR_SRC/shell.toml" "$CONFIG_DIR/shell.toml"
    cp -- "$BAR_SRC/modules/arch-menu.qml" "$CONFIG_DIR/bar/modules/arch-menu.qml"
    rm -rf -- "$CONFIG_DIR/plugins/user.pill-bar"
    cp -r -- "$BAR_SRC/plugins/user.pill-bar" "$CONFIG_DIR/plugins/"

    omarchy-shell -q shell rescanPlugins || true
    omarchy-shell -q shell reloadConfig || true
    echo "✓ Top bar installed (shell.json, shell.toml, arch-menu, user.pill-bar)"
  else
    echo "! Bar payload not found at $BAR_SRC" >&2
  fi
else
  echo ":: Skipping top bar (--no-bar)"
fi

# ---------------------------------------------------------------------------
# 3. Remove stale legacy hook from the Omarchy 3.x version of this theme
# ---------------------------------------------------------------------------
if [[ -f $LEGACY_HOOK ]] && grep -q "Installed by pixel-art theme" "$LEGACY_HOOK" 2>/dev/null; then
  rm -f "$LEGACY_HOOK"
  echo "✓ Removed legacy theme-set hook (replaced by theme-set.d)"
fi

# ---------------------------------------------------------------------------
# 4. Install persistence hook (additive — lives in theme-set.d)
# ---------------------------------------------------------------------------
mkdir -p "$(dirname "$HOOK_FILE")"

cat > "$HOOK_FILE" << 'HOOK'
#!/bin/bash
# Installed by pixel-art theme — re-links bundled Pixora icons on every
# theme switch so they never go missing when Omarchy re-stages themes.
# The pack keeps ~1049 icon aliases as symlinks and Omarchy's staging skips
# them, so link to the git clone where the aliases are still intact.
# Also force-syncs the wallpaper: Quattro's shell reads the background
# symlink only at startup / via IPC, so a missed IPC during a switch
# leaves the old image on screen.
# Called by omarchy-hook theme-set <theme-name> [args...].

[[ ${1:-} == "pixel-art" ]] || exit 0

THEME_NAME="pixel-art"
CLONE_DIR="$HOME/.config/omarchy/themes/$THEME_NAME"
CURRENT_THEME_DIR="$HOME/.local/state/omarchy/current/theme"
ICON_DST="$HOME/.local/share/icons"
STAMP="$(date +%Y%m%d%H%M%S)"

install_icon_link() {
  local src="$1" dst="$2"

  if [[ -L $dst ]]; then
    rm -f -- "$dst"
  elif [[ -e $dst ]]; then
    mv -- "$dst" "$dst.bak.$STAMP"
  fi

  ln -s -- "$src" "$dst"
}

# --- Icons ---
ICONS_SRC="$CLONE_DIR/icons/pixora-icons"
[[ -d $ICONS_SRC ]] || ICONS_SRC="$CURRENT_THEME_DIR/icons/pixora-icons"

if [[ -d $ICONS_SRC ]]; then
  mkdir -p "$ICON_DST"
  install_icon_link "$ICONS_SRC/pixelitos-dark"  "$ICON_DST/pixelitos-dark"
  install_icon_link "$ICONS_SRC/pixelitos-light" "$ICON_DST/pixelitos-light"
  install_icon_link "$ICONS_SRC/icons"           "$ICON_DST/pixora"

  gtk-update-icon-cache "$ICON_DST/pixora"          2>/dev/null || true
  gtk-update-icon-cache "$ICON_DST/pixelitos-dark"  2>/dev/null || true
  gtk-update-icon-cache "$ICON_DST/pixelitos-light" 2>/dev/null || true
fi

# --- Wallpaper sync (best-effort; quiet when shell is not running) ---
omarchy-shell -q background refresh || true
HOOK

chmod +x "$HOOK_FILE"
echo "✓ Persistence hook installed at $HOOK_FILE"

# ---------------------------------------------------------------------------
# 5. Apply icon theme now (omarchy-theme-set-gnome also applies it from
#    icons.theme on every future theme switch)
# ---------------------------------------------------------------------------
gsettings set org.gnome.desktop.interface icon-theme "pixora" 2>/dev/null || true

echo ""
echo "Done! Switch to the theme via Super + Alt + Space → Style → Theme → pixel-art."
