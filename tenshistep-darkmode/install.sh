#!/usr/bin/env bash
#
# Installs the TenshiSTEP-darkmode Plasma theme bundle into the current user's
# ~/.local/share tree. Re-run safely; it overwrites previous copies.
#
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"

echo "Installing TenshiSTEP-darkmode Plasma theme from: $SRC"
echo "Target data dir: $DATA"

# 1. Color scheme
install -d "$DATA/color-schemes"
install -m 644 "$SRC/color-schemes/TenshiSTEP-darkmode.colors" "$DATA/color-schemes/TenshiSTEP-darkmode.colors"
echo "  - color scheme  -> $DATA/color-schemes/TenshiSTEP-darkmode.colors"

# 2. Aurorae window decoration
install -d "$DATA/aurorae/themes/TenshiSTEP-darkmode"
install -m 644 "$SRC/aurorae/TenshiSTEP-darkmode/"* "$DATA/aurorae/themes/TenshiSTEP-darkmode/"
echo "  - window decor  -> $DATA/aurorae/themes/TenshiSTEP-darkmode/"

# 3. Konsole color scheme
install -d "$DATA/konsole"
install -m 644 "$SRC/konsole/TenshiSTEP-darkmode.colorscheme" "$DATA/konsole/TenshiSTEP-darkmode.colorscheme"
[ -f "$SRC/konsole/TenshiSTEP-darkmode.profile" ] && \
  install -m 644 "$SRC/konsole/TenshiSTEP-darkmode.profile" "$DATA/konsole/TenshiSTEP-darkmode.profile"
echo "  - konsole       -> $DATA/konsole/TenshiSTEP-darkmode.{colorscheme,profile}"

# 4. Icon theme (dark set; cp -R preserves the alias symlinks)
install -d "$DATA/icons"
rm -rf "$DATA/icons/TenshiSTEP-darkmode"
cp -R "$SRC/icons/TenshiSTEP-darkmode" "$DATA/icons/TenshiSTEP-darkmode"
echo "  - icon theme    -> $DATA/icons/TenshiSTEP-darkmode/"
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -f -t "$DATA/icons/TenshiSTEP-darkmode" 2>/dev/null || true
fi

# 4b. Cursor theme (TenshiSTEP IRIX). ONE shared Xcursor theme used by BOTH the
#     light and dark Global Themes (cursorTheme=TenshiSTEP-IRIX). It normally
#     lives in the repo sibling dir; also accept a bundled ./cursors/ copy in case
#     this theme dir was lifted out on its own.
CURSORS=""
for _c in "$SRC/../tenshistep-cursors/TenshiSTEP-IRIX" \
          "$SRC/cursors/TenshiSTEP-IRIX" \
          "$SRC/../TenshiSTEP-IRIX"; do
  [ -d "$_c" ] && CURSORS="$_c" && break
done
if [ -n "$CURSORS" ]; then
  # Cursor themes are found via XCURSOR_PATH (~/.icons, /usr/share/icons, ...),
  # which does NOT include ~/.local/share/icons -- so install to ~/.icons, else the
  # cursor KCM never lists it. Also clear any stale copy under ~/.local/share/icons.
  install -d "$HOME/.icons"
  rm -rf "$HOME/.icons/TenshiSTEP-IRIX" "$DATA/icons/TenshiSTEP-IRIX"
  cp -R "$CURSORS" "$HOME/.icons/TenshiSTEP-IRIX"
  echo "  - cursor theme  -> $HOME/.icons/TenshiSTEP-IRIX/ (shared IRIX cursors)"
else
  echo "  !! CURSOR THEME NOT INSTALLED: could not find tenshistep-cursors/TenshiSTEP-IRIX" >&2
  echo "     next to this theme dir. Keep the repo layout intact, or copy that dir to" >&2
  echo "     ./cursors/TenshiSTEP-IRIX and re-run." >&2
fi

# 5. Plasma Style (desktop/widget theme)
install -d "$DATA/plasma/desktoptheme"
rm -rf "$DATA/plasma/desktoptheme/TenshiSTEP-darkmode"
cp -R "$SRC/plasma/desktoptheme/TenshiSTEP-darkmode" "$DATA/plasma/desktoptheme/TenshiSTEP-darkmode"
echo "  - plasma style  -> $DATA/plasma/desktoptheme/TenshiSTEP-darkmode/"

# 5b. Kvantum application style (the chiselled NeXT widget look; needs the
#     Kvantum engine installed for widgetStyle=kvantum to take effect).
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
if [ -d "$SRC/kvantum/TenshiSTEP-darkmode" ]; then
  install -d "$CFG/Kvantum/TenshiSTEP-darkmode"
  install -m 644 "$SRC/kvantum/TenshiSTEP-darkmode/"* "$CFG/Kvantum/TenshiSTEP-darkmode/"
  if command -v kvantummanager >/dev/null 2>&1; then
    kvantummanager --set TenshiSTEP-darkmode >/dev/null 2>&1 || true
  elif [ ! -f "$CFG/Kvantum/kvantum.kvconfig" ]; then
    printf '[General]\ntheme=TenshiSTEP-darkmode\n' > "$CFG/Kvantum/kvantum.kvconfig"
  fi
  echo "  - kvantum style -> $CFG/Kvantum/TenshiSTEP-darkmode/ (widgetStyle=kvantum)"
fi

# 5c. GTK theme (so GTK/GNOME apps match the NeXT look under Plasma)
if [ -d "$SRC/gtk/TenshiSTEP-darkmode" ]; then
  install -d "$DATA/themes/TenshiSTEP-darkmode"
  cp -R "$SRC/gtk/TenshiSTEP-darkmode/"* "$DATA/themes/TenshiSTEP-darkmode/"
  echo "  - gtk theme     -> $DATA/themes/TenshiSTEP-darkmode/ (apply via kde-gtk-config, or"
  echo "                     gsettings set org.gnome.desktop.interface gtk-theme TenshiSTEP-darkmode)"
fi

# 5d. Wallpaper package (selectable in Desktop -> Wallpaper)
if [ -d "$SRC/wallpaper/TenshiSTEP-darkmode" ]; then
  install -d "$DATA/wallpapers"
  rm -rf "$DATA/wallpapers/TenshiSTEP-darkmode"
  cp -R "$SRC/wallpaper/TenshiSTEP-darkmode" "$DATA/wallpapers/TenshiSTEP-darkmode"
  echo "  - wallpaper     -> $DATA/wallpapers/TenshiSTEP-darkmode/ (Desktop -> Wallpaper)"
fi

# 6. Look-and-Feel (Global Theme: ties colours/icons/decoration/splash together)
install -d "$DATA/plasma/look-and-feel"
rm -rf "$DATA/plasma/look-and-feel/org.tenshistep.darkmode.desktop"
cp -R "$SRC/plasma/look-and-feel/org.tenshistep.darkmode.desktop" "$DATA/plasma/look-and-feel/org.tenshistep.darkmode.desktop"
echo "  - global theme  -> $DATA/plasma/look-and-feel/org.tenshistep.darkmode.desktop/"

# 6-style. Point the Global Theme's widgetStyle at the best style actually
# present on THIS system (kvantum / compiled TenshiSTEP QStyle), else keep
# Breeze so applying the theme never yields an unstyled/broken look.
LNF_DEFAULTS="$DATA/plasma/look-and-feel/org.tenshistep.darkmode.desktop/contents/defaults"
WSTYLE=Breeze
# Prefer the bespoke compiled TenshiSTEP-darkmode QStyle when its plugin is
# installed; fall back to the Kvantum engine, then Breeze.
if [ -n "$(find /usr/lib /usr/lib64 /usr/lib/*-linux-gnu -maxdepth 6 \
             -path '*plugins/styles*' -iname 'libtenshistepdarkmodestyle.so' 2>/dev/null | head -n1)" ]; then
  WSTYLE=TenshiSTEP-darkmode
elif command -v kvantummanager >/dev/null 2>&1; then
  WSTYLE=kvantum
fi
if [ -f "$LNF_DEFAULTS" ]; then
  sed -i.bak "s/^widgetStyle=.*/widgetStyle=$WSTYLE/" "$LNF_DEFAULTS" && rm -f "$LNF_DEFAULTS.bak"
fi
echo "  - widget style  -> $WSTYLE (Global Theme default)"
if [ "$WSTYLE" = Breeze ]; then
  echo "                     for the NeXT widgets: install 'kvantum', OR build the"
  echo "                     bundled QStyle (qstyle/build-and-install.sh), then re-run."
fi

# 6a. KWin window switcher (Alt-Tab) skin
if [ -d "$SRC/plasma/kwin/tabbox/org.tenshistep.darkmode.switcher" ]; then
  install -d "$DATA/kwin/tabbox"
  rm -rf "$DATA/kwin/tabbox/org.tenshistep.darkmode.switcher"
  cp -R "$SRC/plasma/kwin/tabbox/org.tenshistep.darkmode.switcher" "$DATA/kwin/tabbox/org.tenshistep.darkmode.switcher"
  echo "  - alt-tab switch-> $DATA/kwin/tabbox/org.tenshistep.darkmode.switcher/"
fi

cat <<'EOF'

Done. Now apply it:

  Color scheme:
    System Settings -> Colors -> "TenshiSTEP-darkmode"
    (or:  plasma-apply-colorscheme TenshiSTEP-darkmode)

  Window decoration:
    System Settings -> Window Decorations -> "TenshiSTEP-darkmode"

  Konsole:
    Konsole -> Settings -> Edit Profile -> Appearance -> "TenshiSTEP-darkmode"

  Icon theme:
    System Settings -> Icons -> "TenshiSTEP-darkmode"
    (or:  plasma-changeicons TenshiSTEP-darkmode)

  Plasma style (widgets):
    System Settings -> Plasma Style -> "TenshiSTEP-darkmode"
    (or:  plasma-apply-desktoptheme TenshiSTEP-darkmode)

  Everything at once (Global Theme):
    System Settings -> Global Theme -> "TenshiSTEP-darkmode"
    (or:  lookandfeeltool -a org.tenshistep.darkmode.desktop)
    To revert:  lookandfeeltool -a org.kde.breeze.desktop

  Cursor + application style:
    The Global Theme applies the TenshiSTEP IRIX cursors automatically. The
    chiselled NeXT WIDGET look needs one of two backends; this installer already
    pointed the Global Theme at whichever it found ("widget style ->" above):
      - Kvantum engine:  Arch: sudo pacman -S kvantum
                         Debian/Ubuntu: sudo apt install qt6-style-kvantum
      - or the bundled compiled QStyle (no engine needed):
                         cd qstyle && ./build-and-install.sh   (needs cmake + Qt dev)
    Install one, then re-run this script so it switches widgetStyle away from
    Breeze. Without either, widgets stay Breeze — nothing breaks.

  Recommended for the full NeXT feel:
    - Fonts: a Helvetica-like face (Nimbus Sans / Liberation Sans) fits best.
    - Window button order: put Minimize on the LEFT and Close on the RIGHT
      under Window Decorations -> Titlebar Buttons.

EOF
