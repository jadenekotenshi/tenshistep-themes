# TenshiSTEP-zirconium QStyle

A native C++ **Qt widget style** (QStyle plugin) — the layer neither a QSS
stylesheet nor Kvantum can fully reach. Because it draws the widgets in code,
it does the things the SVG/stylesheet engines can't:

- **Literal brushed-aluminum streaks** painted into every flat chrome fill
  (buttons, groove backgrounds, spin-box column, progress fill) — faint
  alternating light/dark 1px horizontal lines, the zirconium variant's
  signature over the plain light/dark themes.
- **Scrollbars with both arrows grouped at the far end** (bottom for vertical,
  right for horizontal) — the authentic NeXTSTEP arrangement — and a **centre
  indentation on the scroller knob**.
- **3D metallic progress bars** (vertical gradient groove + glossy steel-blue
  fill).
- Chiselled NeXT bevels on buttons (raised → recessed when pressed), recessed
  line edits with a steel-blue focus frame, white inset check boxes (green
  check) and radio buttons, and framed group boxes / menus.
- The brushed-zirconium palette: bright silver chrome, a cool steel-blue
  accent (replacing the NeXT indigo), unchanged semantic status colours.

It derives from `QProxyStyle("Fusion")`, so any control it doesn't override
still gets sensible Fusion metrics and layout.

## Build & install

Needs a Qt (5 or 6) development environment + CMake. On the target machine:

```bash
./build-and-install.sh
```

or by hand:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build          # into <Qt-plugins>/styles/
```

## Use

```bash
export QT_STYLE_OVERRIDE=TenshiSTEP-zirconium     # any Qt app in this shell
```

In Plasma: **System Settings → Application Style → TenshiSTEP-zirconium**.
Combine it with the TenshiSTEP-zirconium colour scheme, icon theme, and
Aurorae decoration (or just apply the TenshiSTEP-zirconium Global Theme) for
the complete brushed-metal NeXT desktop.

## Status

Built and verified here against Qt 6 / KDE Frameworks 6 (`cmake --build`
succeeds with no warnings) and rendered through `../qstyle-preview/` — the
brushed streaks, chiselled bevels, and steel-blue progress/focus accents all
show up correctly in an actual compiled, offscreen-rendered widget panel
(`qstyle-preview/preview-zirconium.png`). Not yet exercised in a live Plasma
session, so the scrollbar geometry (`subControlRect` +
`drawComplexControl(CC_ScrollBar)`) is still the first thing to eyeball there.
