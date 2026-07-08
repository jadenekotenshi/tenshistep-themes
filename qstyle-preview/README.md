# TenshiSTEP QStyle preview harness

A small offscreen dev tool to eyeball the TenshiSTEP QStyle plugins **without**
installing them or applying them to a live Plasma session. It loads a compiled
style `.so`, applies it to a panel of common widgets (button, checkbox, radio,
combo box, spin box, line edit, slider, progress bar), and renders a PNG.

## Quick start

Build the style plugin(s) first, then run the helper:

```sh
# build a plugin (either theme)
cmake --build ../tenshistep-plasma/qstyle/build --parallel

# build the harness + render both themes -> preview-light.png, preview-dark.png
./render.sh
```

## Direct use

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
./build/styletest <plugin.so> <styleKey> <out.png> [light|dark]
```

Example:

```sh
./build/styletest \
  "$PWD/../tenshistep-plasma/qstyle/build/libtenshistepstyle.so" \
  TenshiSTEP out.png light
```

Style keys: **`TenshiSTEP`** (light), **`TenshiSTEP-darkmode`** (dark).

## Gotchas

- **Use an absolute path to the plugin `.so`.** `QPluginLoader` resolves relative
  paths against the current working directory; if it can't find the file it just
  prints `The shared library was not found.` and the render silently uses no
  custom style. `render.sh` already passes absolute paths.
- Uses `QT_QPA_PLATFORM=offscreen`, so no X/Wayland display is required.
- The plugin must be built against the same Qt major version as this harness
  (both pick Qt6 first via CMake).

## Tip

Zoom in on a control to check pixel-level details:

```sh
magick preview-light.png -crop 60x50+300+150 +repage -filter point -resize 800% zoom.png
```
