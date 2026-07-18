#!/usr/bin/env bash
#
# Installs the TenshiSTEP-zirconium Kvantum theme for the current user.
#
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/TenshiSTEP-zirconium"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/Kvantum/TenshiSTEP-zirconium"

install -d "$DEST"
install -m 644 "$SRC/TenshiSTEP-zirconium.kvconfig" "$DEST/TenshiSTEP-zirconium.kvconfig"
install -m 644 "$SRC/TenshiSTEP-zirconium.svg"      "$DEST/TenshiSTEP-zirconium.svg"
echo "Installed Kvantum theme -> $DEST"
echo
echo "Activate it:"
echo "  kvantummanager --set TenshiSTEP-zirconium"
echo "Then make Qt apps use the Kvantum engine:"
echo "  System Settings -> Application Style -> Kvantum   (Plasma)"
echo "  or set Style=kvantum in qt5ct / qt6ct             (other DEs)"
