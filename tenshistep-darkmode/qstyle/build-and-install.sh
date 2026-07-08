#!/usr/bin/env bash
#
# Builds the TenshiSTEP-darkmode QStyle plugin and installs it into the Qt plugins
# styles/ directory (install step uses sudo if that path is system-owned).
#
# Installs as libtenshistepdarkmodestyle.so — a distinct filename from the light
# TenshiSTEP style (libtenshistepstyle.so), so both can live in styles/ at once.
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
  export QT_STYLE_OVERRIDE=TenshiSTEP-darkmode      # any Qt app in this shell
  # or, in Plasma: System Settings -> Colours & Themes -> Application Style -> TenshiSTEP-darkmode
  # verify it loaded:  QT_STYLE_OVERRIDE=TenshiSTEP-darkmode qtdiag | grep -i style   (or just launch an app)
EOF
