#!/usr/bin/env bash
#
# Installs the TenshiSTEP-darkmode Plymouth boot splash system-wide (requires sudo).
# It copies the theme; setting it as default rebuilds the initramfs, so that
# step is left for you to run explicitly.
#
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tenshistep-darkmode"
DEST=/usr/share/plymouth/themes/tenshistep-darkmode

echo "Installing Plymouth theme:"
echo "  from: $SRC"
echo "  to:   $DEST   (requires sudo)"
sudo mkdir -p "$DEST"
sudo cp "$SRC"/tenshistep-darkmode.plymouth "$SRC"/tenshistep-darkmode.script "$SRC"/*.png "$DEST/"

cat <<'EOF'

Set it as the default boot theme (this rebuilds the initramfs):

  Fedora / Arch / most distros:
    sudo plymouth-set-default-theme -R tenshistep-darkmode

  Debian / Ubuntu:
    sudo update-alternatives --install \
      /usr/share/plymouth/themes/default.plymouth default.plymouth \
      /usr/share/plymouth/themes/tenshistep-darkmode/tenshistep-darkmode.plymouth 100
    sudo update-alternatives --config default.plymouth
    sudo update-initramfs -u

Preview it without rebooting:
  sudo plymouthd ; sudo plymouth --show-splash ; sleep 6 ; sudo plymouth --quit
EOF
