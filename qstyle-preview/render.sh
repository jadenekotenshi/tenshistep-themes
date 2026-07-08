#!/usr/bin/env bash
#
# Build the preview harness and render both TenshiSTEP QStyle plugins to PNGs.
# Build the plugin(s) first (each theme's qstyle/build-and-install.sh, or just
# `cmake --build <theme>/qstyle/build`); this script only needs the built .so.
#
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"

cmake -S "$HERE" -B "$HERE/build" -DCMAKE_BUILD_TYPE=Release >/dev/null
cmake --build "$HERE/build" --parallel >/dev/null
BIN="$HERE/build/styletest"

render() { # <plugin.so> <styleKey> <out.png> <light|dark>
  if [ ! -f "$1" ]; then
    echo "  !! plugin not built: $1" >&2
    echo "     build it: cmake --build \"$(dirname "$1")\" --parallel" >&2
    return 0
  fi
  "$BIN" "$1" "$2" "$3" "$4" && echo "  wrote $3"
}

echo "Rendering TenshiSTEP style previews:"
render "$REPO/tenshistep-plasma/qstyle/build/libtenshistepstyle.so" \
       TenshiSTEP "$HERE/preview-light.png" light
render "$REPO/tenshistep-darkmode/qstyle/build/libtenshistepdarkmodestyle.so" \
       TenshiSTEP-darkmode "$HERE/preview-dark.png" dark
echo "Done."
