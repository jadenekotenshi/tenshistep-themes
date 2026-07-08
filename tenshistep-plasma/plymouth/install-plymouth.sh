#!/usr/bin/env bash
#
# Installs the TenshiSTEP Plymouth boot splash system-wide (requires sudo).
# It copies the theme; setting it as default rebuilds the initramfs, so that
# step is left for you to run explicitly.
#
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tenshistep"
DEST=/usr/share/plymouth/themes/tenshistep

echo "Installing Plymouth theme:"
echo "  from: $SRC"
echo "  to:   $DEST   (requires sudo)"
sudo mkdir -p "$DEST"
sudo cp "$SRC"/tenshistep.plymouth "$SRC"/tenshistep.script "$SRC"/*.png "$DEST/"

cat <<'EOF'

Set it as the default boot theme (this rebuilds the initramfs):

  Fedora / Arch / most distros:
    sudo plymouth-set-default-theme -R tenshistep

  Debian / Ubuntu:
    sudo update-alternatives --install \
      /usr/share/plymouth/themes/default.plymouth default.plymouth \
      /usr/share/plymouth/themes/tenshistep/tenshistep.plymouth 100
    sudo update-alternatives --config default.plymouth
    sudo update-initramfs -u

Preview it without rebooting:
  sudo plymouthd ; sudo plymouth --show-splash ; sleep 6 ; sudo plymouth --quit
EOF
