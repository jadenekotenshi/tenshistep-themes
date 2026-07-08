#!/usr/bin/env bash
#
# Builds the TenshiSTEP QStyle plugin and installs it into the Qt plugins
# styles/ directory (install step uses sudo if that path is system-owned).
#
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cmake -S "$HERE" -B "$HERE/build" -DCMAKE_BUILD_TYPE=Release
cmake --build "$HERE/build" --parallel

echo
echo "Installing the plugin (sudo may be requested):"
sudo cmake --install "$HERE/build" || cmake --install "$HERE/build"

cat <<'EOF'

Done. Use it:
  export QT_STYLE_OVERRIDE=TenshiSTEP      # any Qt app in this shell
  # or, in Plasma: System Settings -> Colours & Themes -> Application Style -> TenshiSTEP
  # verify it loaded:  QT_STYLE_OVERRIDE=TenshiSTEP qtdiag | grep -i style   (or just launch an app)
EOF
