# Pixel Art Theme

A retro-inspired Omarchy theme that brings pixel-art aesthetics to your desktop. With nostalgic design elements, it captures the idea of classic 8-bit and 16-bit games and maintains everyday use.

![Pixel-Art Preview](preview.png)

## Installation

### Via Omarchy Menu

1. Press **Super + Alt + Space** → **Install** → **Style** → **Theme**
2. Paste this repo's GitHub URL and confirm
3. After the theme is applied, run the one-time setup:

```bash
bash ~/.config/omarchy/themes/pixel-art/install.sh
```

This installs:
- **Pixora icon pack** — symlinked to `~/.local/share/icons/`
- **Waybar config** — custom `style.css` + `config.jsonc` deployed to `~/.config/waybar/`
- **Theme-set hook** — re-applies icons + waybar automatically on every theme switch

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

- **Gruvu Theme** by [ankur311sudo](https://github.com/ankur311sudo/gruvu) - Used as the foundation for the Walker application launcher configuration (`walker.css`).
- **Pixora Icons** by [OcyOny](https://github.com/OcyOny/pixora-icons) - Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
- **Gruvbox Theme for VS Code** by [jdinhlife](https://github.com/jdinhlife/vscode-gruvbox) - Used for styling code editor configurations.

## License

MIT
