#!/usr/bin/env bash
#
# Installs the TenshiSTEP Kvantum theme for the current user.
#
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/TenshiSTEP"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/Kvantum/TenshiSTEP"

install -d "$DEST"
install -m 644 "$SRC/TenshiSTEP.kvconfig" "$DEST/TenshiSTEP.kvconfig"
install -m 644 "$SRC/TenshiSTEP.svg"      "$DEST/TenshiSTEP.svg"
echo "Installed Kvantum theme -> $DEST"
echo
echo "Activate it:"
echo "  kvantummanager --set TenshiSTEP"
echo "Then make Qt apps use the Kvantum engine:"
echo "  System Settings -> Application Style -> Kvantum   (Plasma)"
echo "  or set Style=kvantum in qt5ct / qt6ct             (other DEs)"
