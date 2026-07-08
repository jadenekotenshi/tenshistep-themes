#!/usr/bin/env bash
#
# Mirror the canonical TenshiSTEP IRIX cursor theme into the per-theme bundles
# so all copies stay byte-identical. This COPIES (it does not regenerate), so it
# is safe to run after either ./gen_cursors.py or a hand edit of the canonical
# theme. gen_cursors.py runs this automatically after a rebuild.
#
#   canonical:  tenshistep-cursors/TenshiSTEP-IRIX
#   bundles:    tenshistep-plasma/cursors/TenshiSTEP-IRIX
#               tenshistep-darkmode/cursors/TenshiSTEP-IRIX
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"     # tenshistep-cursors/tools
SRC="$(cd "$HERE/.." && pwd)/TenshiSTEP-IRIX"            # canonical theme
ROOT="$(cd "$HERE/../.." && pwd)"                        # repo root

[ -d "$SRC" ] || { echo "sync-bundles: canonical theme not found: $SRC" >&2; exit 1; }

for t in tenshistep-plasma tenshistep-darkmode; do
  dest="$ROOT/$t/cursors/TenshiSTEP-IRIX"
  install -d "$ROOT/$t/cursors"
  rm -rf "$dest"
  cp -R "$SRC" "$dest"                                   # cp -R preserves the alias symlinks
  echo "sync-bundles: $t/cursors/TenshiSTEP-IRIX  <-  tenshistep-cursors/TenshiSTEP-IRIX"
done
