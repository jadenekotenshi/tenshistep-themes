#!/usr/bin/env bash
#
# Installs the TenshiSTEP-darkmode SDDM login theme system-wide (requires sudo,
# since SDDM themes live under /usr/share). Then point SDDM at it.
#
set -euo pipefail

# Usage: install-sddm.sh [qt5|qt6]   (default: qt5)
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARIANT="${1:-qt5}"
case "$VARIANT" in
  qt5) SRC="$HERE/TenshiSTEP-darkmode" ;;
  qt6) SRC="$HERE/qt6/TenshiSTEP-darkmode" ;;
  *) echo "unknown variant '$VARIANT' (use qt5 or qt6)"; exit 1 ;;
esac
DEST=/usr/share/sddm/themes/TenshiSTEP-darkmode

echo "Installing SDDM theme ($VARIANT):"
echo "  from: $SRC"
echo "  to:   $DEST   (requires sudo)"
sudo mkdir -p "$DEST"
sudo cp -R "$SRC/." "$DEST/"

echo
echo "Activate it by creating /etc/sddm.conf.d/tenshistep.conf with:"
echo
echo "  [Theme]"
echo "  Current=TenshiSTEP-darkmode"
echo
echo "Preview/verify without logging out:"
echo "  sddm-greeter --test-mode --theme $DEST"
