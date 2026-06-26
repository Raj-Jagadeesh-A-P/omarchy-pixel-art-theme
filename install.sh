#!/bin/bash

# install.sh
# Run once after `omarchy theme install <url>` to:
#   1. Install the bundled Pixora icon pack system-wide
#   2. Deploy the custom Waybar style and config
#   3. Create a theme-set hook so everything persists on theme switch
#
# Usage: bash ~/.config/omarchy/themes/pixel-art/install.sh

THEME_DIR="$HOME/.config/omarchy/themes/pixel-art"
CURRENT_THEME_DIR="$HOME/.config/omarchy/current/theme"
HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"

set -e

# ---------------------------------------------------------------------------
# 1. Install Pixora icon themes
# ---------------------------------------------------------------------------
ICONS_SRC="$CURRENT_THEME_DIR/icons/pixora-icons"
ICONS_DST="$HOME/.local/share/icons"

echo ":: Installing Pixora icon themes → $ICONS_DST"
mkdir -p "$ICONS_DST"
ln -sf "$ICONS_SRC/pixelitos-dark"  "$ICONS_DST/pixelitos-dark"
ln -sf "$ICONS_SRC/pixelitos-light" "$ICONS_DST/pixelitos-light"
ln -sf "$ICONS_SRC/icons"           "$ICONS_DST/pixora"

gtk-update-icon-cache "$ICONS_DST/pixora"         2>/dev/null || true
gtk-update-icon-cache "$ICONS_DST/pixelitos-dark" 2>/dev/null || true
gtk-update-icon-cache "$ICONS_DST/pixelitos-light" 2>/dev/null || true
echo "✓ Icon themes installed: pixora, pixelitos-dark, pixelitos-light"

# ---------------------------------------------------------------------------
# 2. Deploy Waybar config
# ---------------------------------------------------------------------------
WAYBAR_SRC="$CURRENT_THEME_DIR/waybar"
WAYBAR_DST="$HOME/.config/waybar"

if [ -d "$WAYBAR_SRC" ]; then
  echo ":: Deploying Waybar config → $WAYBAR_DST"
  mkdir -p "$WAYBAR_DST"

  if [ -f "$WAYBAR_DST/style.css" ]; then
    cp "$WAYBAR_DST/style.css" "$WAYBAR_DST/style.css.bak.$(date +%s)"
    echo "  → backed up existing style.css"
  fi
  cp "$WAYBAR_SRC/style.css" "$WAYBAR_DST/style.css"

  if [ -f "$WAYBAR_DST/config.jsonc" ]; then
    cp "$WAYBAR_DST/config.jsonc" "$WAYBAR_DST/config.jsonc.bak.$(date +%s)"
    echo "  → backed up existing config.jsonc"
  fi
  cp "$WAYBAR_SRC/config.jsonc" "$WAYBAR_DST/config.jsonc"

  echo "✓ Waybar config deployed"

  if pgrep -x waybar >/dev/null; then
    echo "  → restarting waybar..."
    pkill -9 -x waybar
    setsid uwsm-app -- waybar >/dev/null 2>&1 &
    echo "  → waybar restarted"
  fi
fi

# ---------------------------------------------------------------------------
# 3. Install / update the theme-set hook
# ---------------------------------------------------------------------------
mkdir -p "$(dirname "$HOOK_FILE")"

if [ -f "$HOOK_FILE" ]; then
  echo "  → theme-set hook exists — updating with waybar support"
fi

cat > "$HOOK_FILE" << 'HOOK'
#!/bin/bash
# Installed by pixel-art theme — re-links Pixora icons and re-deploys
# Waybar config on every theme switch.
# This hook is called automatically by omarchy-theme-set after a theme change.

THEME_DIR="$HOME/.config/omarchy/current/theme"

# --- Icons ---
ICONS_SRC="$THEME_DIR/icons/pixora-icons"
ICONS_DST="$HOME/.local/share/icons"

if [ -d "$ICONS_SRC" ]; then
  mkdir -p "$ICONS_DST"
  ln -sf "$ICONS_SRC/pixelitos-dark"  "$ICONS_DST/pixelitos-dark"
  ln -sf "$ICONS_SRC/pixelitos-light" "$ICONS_DST/pixelitos-light"
  ln -sf "$ICONS_SRC/icons"           "$ICONS_DST/pixora"
  gtk-update-icon-cache "$ICONS_DST/pixora"         2>/dev/null || true
  gtk-update-icon-cache "$ICONS_DST/pixelitos-dark" 2>/dev/null || true
  gtk-update-icon-cache "$ICONS_DST/pixelitos-light" 2>/dev/null || true
fi

# --- Waybar ---
WAYBAR_SRC="$THEME_DIR/waybar"
WAYBAR_DST="$HOME/.config/waybar"

if [ -d "$WAYBAR_SRC" ]; then
  mkdir -p "$WAYBAR_DST"
  cp "$WAYBAR_SRC/style.css"    "$WAYBAR_DST/style.css"
  cp "$WAYBAR_SRC/config.jsonc" "$WAYBAR_DST/config.jsonc"
  if pgrep -x waybar >/dev/null; then
    pkill -9 -x waybar
    setsid uwsm-app -- waybar >/dev/null 2>&1 &
  fi
fi
HOOK
chmod +x "$HOOK_FILE"
echo "✓ theme-set hook installed at $HOOK_FILE"

# ---------------------------------------------------------------------------
# 4. Apply icon theme
# ---------------------------------------------------------------------------
gsettings set org.gnome.desktop.interface icon-theme "pixora" 2>/dev/null || true

echo ""
echo "Done! Everything is set up."
echo "If you switch themes later, the hook will re-apply icons + waybar automatically."
