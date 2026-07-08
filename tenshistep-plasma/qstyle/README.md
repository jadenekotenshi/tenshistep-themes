# TenshiSTEP QStyle

A native C++ **Qt widget style** (QStyle plugin) — the layer neither a QSS
stylesheet nor Kvantum can fully reach. Because it draws the widgets in code,
it does the things the SVG/stylesheet engines can't:

- **Scrollbars with both arrows grouped at the far end** (bottom for vertical,
  right for horizontal) — the authentic NeXTSTEP arrangement — and a **centre
  indentation on the scroller knob**.
- **3D metallic progress bars** (vertical gradient groove + glossy fill).
- Chiselled NeXT bevels on buttons (raised → recessed when pressed), recessed
  line edits with an indigo focus frame, white inset check boxes (green
  check) and radio buttons, and framed group boxes / menus.
- The full OPENSTEP-muted palette.

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
export QT_STYLE_OVERRIDE=TenshiSTEP     # any Qt app in this shell
```

In Plasma: **System Settings → Application Style → TenshiSTEP**. Combine it
with the TenshiSTEP colour scheme, icon theme, and Aurorae decoration (or
just apply the TenshiSTEP Global Theme) for the complete NeXT desktop.

## Status

Written to the documented QStyle API and structured to compile against **Qt 5
and Qt 6** (CMake auto-detects), but it was authored without a Qt build
environment on hand, so treat the first `cmake --build` as the real check and
expect to tweak a metric or two. The scrollbar geometry (`subControlRect` +
`drawComplexControl(CC_ScrollBar)`) and the progress-bar/bevel painting are the
parts to eyeball first.
