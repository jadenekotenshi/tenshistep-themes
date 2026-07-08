#!/usr/bin/env bash
#
# Install a TenshiSTEP rEFInd theme.
#   install-refind.sh <refind-dir> [dark]
# where <refind-dir> is your rEFInd directory on the ESP, e.g.
#   /boot/efi/EFI/refind   or   /boot/EFI/refind
#
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REFIND="${1:-}"
VARIANT="${2:-light}"
case "$VARIANT" in
  light) NAME="TenshiSTEP" ;;
  dark)  NAME="TenshiSTEP-dark" ;;
  *) echo "unknown variant '$VARIANT' (use 'light' or 'dark')"; exit 1 ;;
esac

if [ -z "$REFIND" ] || [ ! -d "$REFIND" ]; then
  echo "usage: $0 <refind-dir> [dark]"
  echo "  <refind-dir> must be your rEFInd folder on the ESP, e.g. /boot/efi/EFI/refind"
  echo "  common candidates on this system:"
  for c in /boot/efi/EFI/refind /boot/EFI/refind /efi/EFI/refind; do
    [ -d "$c" ] && echo "    $c"
  done
  exit 1
fi

echo "Installing '$NAME' -> $REFIND/themes/$NAME"
mkdir -p "$REFIND/themes"
rm -rf "$REFIND/themes/$NAME"
cp -r "$HERE/$NAME" "$REFIND/themes/$NAME"

INC="include themes/$NAME/theme.conf"
CONF="$REFIND/refind.conf"
if [ -f "$CONF" ] && ! grep -qxF "$INC" "$CONF"; then
  echo "" >> "$CONF"
  echo "$INC" >> "$CONF"
  echo "Added to $CONF:  $INC"
else
  echo "Add this line to $CONF (once):"
  echo "  $INC"
fi
echo "Done. Reboot to see it."
