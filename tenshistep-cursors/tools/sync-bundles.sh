#!/usr/bin/env bash
#
# Mirror the canonical TenshiSTEP-CURSORS cursor theme into the per-theme bundles
# so all copies stay byte-identical. This COPIES (it does not regenerate), so it
# is safe to run after either ./gen_cursors.py or a hand edit of the canonical
# theme. gen_cursors.py runs this automatically after a rebuild.
#
#   canonical:  tenshistep-cursors/TenshiSTEP-CURSORS
#   bundles:    tenshistep-plasma/cursors/TenshiSTEP-CURSORS
#               tenshistep-darkmode/cursors/TenshiSTEP-CURSORS
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"     # tenshistep-cursors/tools
SRC="$(cd "$HERE/.." && pwd)/TenshiSTEP-CURSORS"            # canonical theme
ROOT="$(cd "$HERE/../.." && pwd)"                        # repo root

[ -d "$SRC" ] || { echo "sync-bundles: canonical theme not found: $SRC" >&2; exit 1; }

for t in tenshistep-plasma tenshistep-darkmode; do
  dest="$ROOT/$t/cursors/TenshiSTEP-CURSORS"
  install -d "$ROOT/$t/cursors"
  rm -rf "$dest"
  cp -R "$SRC" "$dest"                                   # cp -R preserves the alias symlinks
  echo "sync-bundles: $t/cursors/TenshiSTEP-CURSORS  <-  tenshistep-cursors/TenshiSTEP-CURSORS"
done
