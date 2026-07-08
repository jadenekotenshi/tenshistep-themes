# TenshiSTEP — a NeXTSTEP/OPENSTEP theme suite for KDE Plasma

A complete NeXTSTEP / OPENSTEP-inspired desktop and boot theme, branded
**TenshiNET** (emblem: a stylized OPENSTEP angel), in coordinated **light** and
**dark** variants.

## Bundles

| Directory | What it is |
|---|---|
| `tenshistep-plasma/` | The light theme: Global Theme, colour scheme, Aurorae decoration, Konsole, Plasma style, Kvantum/QSS/QStyle, GTK3/4 theme, icon theme (~1,650 files — 588 apps, 521 mimetypes, 199 actions, 202 status, 106 devices), wallpaper package, SDDM, Plymouth, launchers, MIME types, and the software-update stack. Run `install.sh`. |
| `tenshistep-darkmode/` | The dark variant (`TenshiSTEP-darkmode`) — icons, colours, Aurorae, Plasma style, Kvantum, GTK theme, wallpaper. |
| `tenshistep-cursors/` | The **TenshiSTEP-CURSORS** Xcursor theme (SGI IRIX / 4Dwm idiom); wired into both Global Themes. |
| `tenshistep-refind/` | rEFInd boot theme (light + dark) with 46 OS icons and HiDPI EFI splashes. |
| `demo/` | The `EFI → rEFInd → Plymouth → SDDM → desktop` boot-sequence animation. |
| `packaging/` | Arch `PKGBUILD` + AppStream MetaInfo for system-wide / KDE-Store distribution. |

## Install (Plasma)

```sh
cd tenshistep-plasma
./install.sh
```

Then apply it under **System Settings → Global Theme → "TenshiSTEP"** (or
`lookandfeeltool -a org.tenshistep.desktop`). The installer prints per-component
instructions and sets up the update notifier, KRunner action and plasmoid.

Applying the Global Theme now also sets the **IRIX cursors** and the **Kvantum**
widget style automatically. For Kvantum to render, install its engine
(`kvantum` / `qt6-style-kvantum`); without it, Qt falls back to Breeze.

For the boot theme, see the `tenshistep-refind/` bundle.

## Gallery

Rendered preview sheets live under `tenshistep-plasma/previews/` and
`tenshistep-refind/previews/`, e.g.:

| Preview | File |
|---|---|
| Desktop | `previews/desktop.png` |
| SDDM login | `previews/login.png` |
| rEFInd boot menu (light/dark) | `tenshistep-refind/previews/boot-light.png`, `boot-dark.png` |
| App icons | `previews/apps-more.png`, `previews/icons-os-apps.png` |
| MIME icons | `previews/mimetypes.png` (+ scientific / system / formats / packages sheets) |
| Window decoration | `previews/window-decoration.png` |
| Boot handoff | `previews/plymouth-handoff.png` |

## Status

See [CHANGELOG.md](CHANGELOG.md). Current release: **0.1.0**.

Assets were authored and validated via an SVG→PNG mock pipeline; icons are
NeXT-idiom reinterpretations rather than official logos. Verify on live KDE.
