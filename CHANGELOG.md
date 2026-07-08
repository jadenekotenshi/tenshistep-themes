# Changelog

All notable changes to the **TenshiSTEP / TenshiNET** theme suite are documented
here. Format based on [Keep a Changelog](https://keepachangelog.com/); this
project follows [Semantic Versioning](https://semver.org/).

## [0.1.0] — 2026-07-08

Initial release of **TenshiSTEP** — a NeXTSTEP / OPENSTEP-inspired KDE Plasma
theme suite spanning the whole boot-to-desktop chain, in coordinated **light**
and **dark** variants. (Previously developed under the name *AngelLevel*; the
suite was renamed and its versioning restarted at 0.1.0.)

### Plasma Global Themes — light (`tenshistep-plasma`) + dark (`tenshistep-darkmode`)
- **Look-and-Feel** Global Themes (`org.tenshistep.desktop`, `…darkmode.desktop`)
  tying colours, icons, decoration and splash together, with a stylized OPENSTEP
  angel as the application-launcher icon.
- **Colour schemes**, **Aurorae** window decoration (NeXT 9-slice bevels,
  symmetric close-X, chunky bottom resize bar), **Konsole** schemes, **Plasma
  Style**, **GTK3/4** themes, **wallpapers**, and an **Alt-Tab** switcher.
- **Icon theme** — ~1,000 hand-authored NeXT-idiom icons per variant across
  apps / mimetypes / actions / status / devices / places / emblems, plus 56
  monochrome symbolic tray glyphs; the dark variant is recoloured for a dark
  desktop. Includes a wrapping-fox Firefox icon and the angel menu launcher.

### Widget styling
- A compiled NeXT-style **QStyle** (`TenshiSTEPStyle` / `TenshiSTEP-darkmode`):
  chiselled bevels, a grey raised checkbox with a silvery check, and raised
  combo/spin controls. A **Kvantum** theme and **QSS** are provided as
  alternatives; `install.sh` prefers the compiled QStyle when installed, then
  Kvantum, else Breeze.
- An offscreen **QStyle preview harness** (`qstyle-preview/`).

### Cursors & boot chain
- Shared **TenshiSTEP-CURSORS** SGI-idiom Xcursor set (69 cursors), installed to
  `~/.icons` so the cursor KCM lists it.
- **SDDM** greeter, **Plymouth** splash, and a **rEFInd** boot theme (light +
  dark) with banner, OS icons and HiDPI EFI splashes — a canonical angel
  position is carried across EFI → rEFInd → Plymouth → SDDM → desktop.

### Applications, MIME & updates
- Branded `.desktop` launchers, shared-mime-info definitions with content magic,
  and a `tenshistep-update-notifier` stack (systemd user timer, KRunner runner,
  updates plasmoid) covering pacman / apt / dnf / zypper / flatpak.

### Packaging & install
- Per-theme `install.sh` deploying every component into `~/.local`, a **PKGBUILD**
  for a system-wide Arch install, and **AppStream** metainfo.

[0.1.0]: https://github.com/jadenekotenshi/tenshistep-themes/releases/tag/0.1.0
