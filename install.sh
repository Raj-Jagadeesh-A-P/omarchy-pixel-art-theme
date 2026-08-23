#!/bin/bash

# install.sh
# Run once after `omarchy theme install <url>` to:
#   1. Install the bundled Pixora icon pack
#   2. Create a theme-set.d hook so icons persist on every theme switch
#
# Omarchy 4+ (Quattro). The shell, bar, launcher, notifications and lock
# screen are themed automatically from colors.toml — no extra setup needed.
#
# Usage: bash ~/.config/omarchy/themes/pixel-art/install.sh

set -e

THEME_NAME="pixel-art"
THEME_DIR="$HOME/.config/omarchy/themes/$THEME_NAME"
CURRENT_THEME_DIR="$HOME/.local/state/omarchy/current/theme"
HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set.d/$THEME_NAME-icons.sh"
LEGACY_HOOK="$HOME/.config/omarchy/hooks/theme-set"

# ---------------------------------------------------------------------------
# 1. Install Pixora icon themes
# ---------------------------------------------------------------------------
install_icons() {
  local src="$1"
  local dst="$HOME/.local/share/icons"

  mkdir -p "$dst"
  ln -sfn "$src/pixelitos-dark"  "$dst/pixelitos-dark"
  ln -sfn "$src/pixelitos-light" "$dst/pixelitos-light"
  ln -sfn "$src/icons"           "$dst/pixora"

  gtk-update-icon-cache "$dst/pixora"         2>/dev/null || true
  gtk-update-icon-cache "$dst/pixelitos-dark" 2>/dev/null || true
  gtk-update-icon-cache "$dst/pixelitos-light" 2>/dev/null || true
}

# Prefer the staged copy in the current theme, fall back to this repo clone.
ICONS_SRC="$CURRENT_THEME_DIR/icons/pixora-icons"
[[ -d $ICONS_SRC ]] || ICONS_SRC="$THEME_DIR/icons/pixora-icons"

if [[ -d $ICONS_SRC ]]; then
  echo ":: Installing Pixora icon themes → $HOME/.local/share/icons"
  install_icons "$ICONS_SRC"
  echo "✓ Icon themes installed: pixora, pixelitos-dark, pixelitos-light"
else
  echo "! Bundled icons not found (looked in $CURRENT_THEME_DIR and $THEME_DIR)" >&2
fi

# ---------------------------------------------------------------------------
# 2. Remove stale legacy hook from the Omarchy 3.x version of this theme
# ---------------------------------------------------------------------------
if [[ -f $LEGACY_HOOK ]] && grep -q "Installed by pixel-art theme" "$LEGACY_HOOK" 2>/dev/null; then
  rm -f "$LEGACY_HOOK"
  echo "✓ Removed legacy theme-set hook (replaced by theme-set.d)"
fi

# ---------------------------------------------------------------------------
# 3. Install persistence hook (additive — lives in theme-set.d)
# ---------------------------------------------------------------------------
mkdir -p "$(dirname "$HOOK_FILE")"

cat > "$HOOK_FILE" << 'HOOK'
#!/bin/bash
# Installed by pixel-art theme — re-links bundled Pixora icons on every
# theme switch so they never go missing when Omarchy re-stages themes.
# Called by omarchy-hook theme-set <theme-name>.

THEME_NAME="pixel-art"
CURRENT_THEME_DIR="$HOME/.local/state/omarchy/current/theme"
FALLBACK_DIR="$HOME/.config/omarchy/themes/$THEME_NAME"
ICON_DST="$HOME/.local/share/icons"

ICONS_SRC="$CURRENT_THEME_DIR/icons/pixora-icons"
[[ -d $ICONS_SRC ]] || ICONS_SRC="$FALLBACK_DIR/icons/pixora-icons"
[[ -d $ICONS_SRC ]] || exit 0

mkdir -p "$ICON_DST"
ln -sfn "$ICONS_SRC/pixelitos-dark"  "$ICON_DST/pixelitos-dark"
ln -sfn "$ICONS_SRC/pixelitos-light" "$ICON_DST/pixelitos-light"
ln -sfn "$ICONS_SRC/icons"           "$ICON_DST/pixora"

gtk-update-icon-cache "$ICON_DST/pixora"         2>/dev/null || true
gtk-update-icon-cache "$ICON_DST/pixelitos-dark" 2>/dev/null || true
gtk-update-icon-cache "$ICON_DST/pixelitos-light" 2>/dev/null || true
HOOK

chmod +x "$HOOK_FILE"
echo "✓ Persistence hook installed at $HOOK_FILE"

# ---------------------------------------------------------------------------
# 4. Apply icon theme now (omarchy-theme-set-gnome also applies it from
#    icons.theme on every future theme switch)
# ---------------------------------------------------------------------------
gsettings set org.gnome.desktop.interface icon-theme "pixora" 2>/dev/null || true

echo ""
echo "Done! Switch to the theme via Super + Alt + Space → Style → Theme → pixel-art."
