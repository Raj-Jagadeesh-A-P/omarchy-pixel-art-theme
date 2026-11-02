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
- **Pixora icon pack** — symlinked to `~/.local/share/icons/` and applied via `icons.theme`. The links point at the theme clone rather than Omarchy's staged copy, because staging strips symlinks and the pack keeps ~1049 icon aliases (plus `pixelitos-light/128`) as symlinks
- **Pixel-art top bar** — deploys `shell.json`, `shell.toml` (`size-horizontal = 30`), `bar/modules/arch-menu.qml` and the `user.pill-bar` plugin into `~/.config/omarchy/`, then rescans plugins and reloads the shell. Existing files are backed up with a `.bak.<timestamp>` suffix. Pass `--no-bar` to skip this step
- **Persistence hook** — lives in `~/.config/omarchy/hooks/theme-set.d/` and re-links the icons on every pixel-art theme switch, so they never disappear when Omarchy re-stages themes. It also force-syncs the wallpaper after each switch (Quattro's shell reads the background symlink only at startup or via IPC)

```bash
# Keep your existing bar configuration:
bash ~/.config/omarchy/themes/pixel-art/install.sh --no-bar
```

## Wallpapers

Seven bundled pixel-art backgrounds live in [`backgrounds/`](backgrounds/) and install with the theme.

- **Super + Ctrl + Space** — open the background switcher
- Or **Super + Alt + Space** → **Style** → **Background**

If the desktop ever shows a stale image after a theme switch, refresh it manually:

```bash
omarchy-shell background refresh
```

## Top bar

`install.sh` deploys the pixel-art pill bar, which uses the custom `user.pill-bar` plugin (three oval pills, 30px tall) plus the retro arch menu on the left. The layout lives in `~/.config/omarchy/shell.json`; size and font are set in `~/.config/omarchy/shell.toml`.

- Customize widgets by editing `~/.config/omarchy/shell.json`, dragging widgets on the bar, or via `omarchy plugin list`
- Change bar height with `[bar] size-horizontal` in `~/.config/omarchy/shell.toml`
- To restore a previous configuration, copy back the matching `*.bak.<timestamp>` file

The clock ships with a 12-hour format (`dddd hh:mm AP`). The workspaces widget uses numbered workspaces 1–5 persistent (up to 10) with a diamond marker on the active one.

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
