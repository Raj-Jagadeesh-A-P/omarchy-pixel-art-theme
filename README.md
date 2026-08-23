# Pixel Art Theme

A retro-inspired theme for **Omarchy 4+ (Quattro)** that brings pixel-art aesthetics to your desktop. With nostalgic design elements, it captures the idea of classic 8-bit and 16-bit games and maintains everyday use.

![Pixel-Art Preview](preview.png)

The Omarchy shell — top bar, launcher, menus, notifications, OSD and lock screen — is themed entirely from `colors.toml`, so everything recolors automatically on switch.

## Installation

### Via Omarchy Menu

1. Press **Super + Alt + Space** → **Install** → **Style** → **Theme**
2. Paste this repo's GitHub URL and confirm
3. After the theme is applied, run the one-time setup:

```bash
bash ~/.config/omarchy/themes/pixel-art/install.sh
```

This installs:
- **Pixora icon pack** — symlinked to `~/.local/share/icons/` and applied via `icons.theme`
- **Persistence hook** — lives in `~/.config/omarchy/hooks/theme-set.d/` and re-links the icons on every theme switch, so they never disappear when Omarchy re-stages themes

## Color Palette

Based on a crafted dark palette:

| Role | Hex | Usage |
|---|---|---|
| Background | `#1D2021` | Base dark background |
| Foreground | `#D5C4A1` | Primary text |
| Red | `#CC241D` / `#EA6962` | Errors, destructive actions |
| Green | `#B8BB26` / `#A9B665` | Success |
| Yellow | `#D79921` / `#E78A4E` | Warnings |
| Blue | `#83A598` / `#7DAEA3` | Links, accents |
| Magenta | `#D3869B` | Secondary accent |
| Cyan | `#8EC07C` / `#89B482` | Information |
| Bright Text | `#EBDBB2` | High-contrast text |

## Credits

This theme bundles or configures assets from the following amazing open-source projects:

- **Pixora Icons** by [OcyOny](https://github.com/OcyOny/pixora-icons) - Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
- **Gruvbox** — palette foundation for `colors.toml`.

## License

MIT
