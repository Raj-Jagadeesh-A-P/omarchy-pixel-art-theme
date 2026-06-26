#!/bin/bash

# install-icons.sh
# Run once after `omarchy theme install <url>` to install the bundled Pixora
# icon pack system-wide and create a theme-set hook so icons persist on switch.
#
# Usage: bash ~/.config/omarchy/themes/pixel-art/install-icons.sh

ICONS_SRC="$HOME/.config/omarchy/current/theme/icons/pixora-icons"
ICONS_DST="$HOME/.local/share/icons"
HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"

set -e

echo ":: Installing Pixora icon themes → $ICONS_DST"

mkdir -p "$ICONS_DST"

# Symlink the three icon sub-themes
ln -sf "$ICONS_SRC/pixelitos-dark"  "$ICONS_DST/pixelitos-dark"
ln -sf "$ICONS_SRC/pixelitos-light" "$ICONS_DST/pixelitos-light"
ln -sf "$ICONS_SRC/icons"           "$ICONS_DST/pixora"

# Update icon caches (non-fatal if gtk-update-icon-cache is missing)
gtk-update-icon-cache "$ICONS_DST/pixora"         2>/dev/null || true
gtk-update-icon-cache "$ICONS_DST/pixelitos-dark" 2>/dev/null || true
gtk-update-icon-cache "$ICONS_DST/pixelitos-light" 2>/dev/null || true

echo "✓ Icon themes installed: pixora, pixelitos-dark, pixelitos-light"

# ---------------------------------------------------------------------------
# Install the theme-set hook so icons are re-linked on every theme switch
# ---------------------------------------------------------------------------
mkdir -p "$(dirname "$HOOK_FILE")"

if [ -f "$HOOK_FILE" ]; then
  echo "  → theme-set hook already exists at $HOOK_FILE (skipping)"
else
  cat > "$HOOK_FILE" << 'HOOK'
#!/bin/bash
# Installed by pixel-art theme — re-links Pixora icons on theme switch.
# This hook is called automatically by omarchy-theme-set after a theme change.

THEME_DIR="$HOME/.config/omarchy/current/theme"
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
HOOK
  chmod +x "$HOOK_FILE"
  echo "✓ theme-set hook created at $HOOK_FILE"
fi

echo ""
echo "Done! Icons will be applied the next time you switch to the pixel-art theme."
echo "Run 'omarchy theme set pixel-art' now to apply."
