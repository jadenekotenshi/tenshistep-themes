#!/usr/bin/env bash
#
# Installs the TenshiSTEP-zirconium Plasma theme bundle into the current user's
# ~/.local/share tree. Re-run safely; it overwrites previous copies.
#
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"

echo "Installing TenshiSTEP-zirconium Plasma theme from: $SRC"
echo "Target data dir: $DATA"

# 1. Color scheme
install -d "$DATA/color-schemes"
install -m 644 "$SRC/color-schemes/TenshiSTEP-zirconium.colors" "$DATA/color-schemes/TenshiSTEP-zirconium.colors"
echo "  - color scheme  -> $DATA/color-schemes/TenshiSTEP-zirconium.colors"

# 2. Aurorae window decoration
install -d "$DATA/aurorae/themes/TenshiSTEP-zirconium"
install -m 644 "$SRC/aurorae/TenshiSTEP-zirconium/"* "$DATA/aurorae/themes/TenshiSTEP-zirconium/"
echo "  - window decor  -> $DATA/aurorae/themes/TenshiSTEP-zirconium/"

# 3. Konsole color scheme
install -d "$DATA/konsole"
install -m 644 "$SRC/konsole/TenshiSTEP-zirconium.colorscheme" "$DATA/konsole/TenshiSTEP-zirconium.colorscheme"
[ -f "$SRC/konsole/TenshiSTEP-zirconium.profile" ] && \
  install -m 644 "$SRC/konsole/TenshiSTEP-zirconium.profile" "$DATA/konsole/TenshiSTEP-zirconium.profile"
echo "  - konsole       -> $DATA/konsole/TenshiSTEP-zirconium.{colorscheme,profile}"

# 4. Icon theme (dark set; cp -R preserves the alias symlinks)
install -d "$DATA/icons"
rm -rf "$DATA/icons/TenshiSTEP-zirconium"
cp -R "$SRC/icons/TenshiSTEP-zirconium" "$DATA/icons/TenshiSTEP-zirconium"
echo "  - icon theme    -> $DATA/icons/TenshiSTEP-zirconium/"
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -f -t "$DATA/icons/TenshiSTEP-zirconium" 2>/dev/null || true
fi

# 4b. Cursor theme (TenshiSTEP-CURSORS -- named distinctly from the "TenshiSTEP"
#     icon theme to avoid a name clash). ONE shared Xcursor theme used by BOTH the
#     light and dark Global Themes (cursorTheme=TenshiSTEP-CURSORS). It normally
#     lives in the repo sibling dir; also accept a bundled ./cursors/ copy in case
#     this theme dir was lifted out on its own.
CURSORS=""
for _c in "$SRC/../tenshistep-cursors/TenshiSTEP-CURSORS" \
          "$SRC/cursors/TenshiSTEP-CURSORS" \
          "$SRC/../TenshiSTEP-CURSORS"; do
  [ -d "$_c" ] && CURSORS="$_c" && break
done
if [ -n "$CURSORS" ]; then
  # Cursor themes are found via XCURSOR_PATH (~/.icons, /usr/share/icons, ...),
  # which does NOT include ~/.local/share/icons -- so install to ~/.icons, else the
  # cursor KCM never lists it. Clear the target plus any stale pre-rename copy (the
  # old TenshiSTEP-IRIX name).
  install -d "$HOME/.icons"
  rm -rf "$HOME/.icons/TenshiSTEP-CURSORS" "$HOME/.icons/TenshiSTEP-IRIX" "$DATA/icons/TenshiSTEP-IRIX"
  cp -R "$CURSORS" "$HOME/.icons/TenshiSTEP-CURSORS"
  echo "  - cursor theme  -> $HOME/.icons/TenshiSTEP-CURSORS/ (shared IRIX-idiom cursors)"
else
  echo "  !! CURSOR THEME NOT INSTALLED: could not find tenshistep-cursors/TenshiSTEP-CURSORS" >&2
  echo "     next to this theme dir. Keep the repo layout intact, or copy that dir to" >&2
  echo "     ./cursors/TenshiSTEP-CURSORS and re-run." >&2
fi

# 5. Plasma Style (desktop/widget theme)
install -d "$DATA/plasma/desktoptheme"
rm -rf "$DATA/plasma/desktoptheme/TenshiSTEP-zirconium"
cp -R "$SRC/plasma/desktoptheme/TenshiSTEP-zirconium" "$DATA/plasma/desktoptheme/TenshiSTEP-zirconium"
echo "  - plasma style  -> $DATA/plasma/desktoptheme/TenshiSTEP-zirconium/"

# 5b. Kvantum application style (the chiselled NeXT widget look; needs the
#     Kvantum engine installed for widgetStyle=kvantum to take effect).
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
if [ -d "$SRC/kvantum/TenshiSTEP-zirconium" ]; then
  install -d "$CFG/Kvantum/TenshiSTEP-zirconium"
  install -m 644 "$SRC/kvantum/TenshiSTEP-zirconium/"* "$CFG/Kvantum/TenshiSTEP-zirconium/"
  if command -v kvantummanager >/dev/null 2>&1; then
    kvantummanager --set TenshiSTEP-zirconium >/dev/null 2>&1 || true
  elif [ ! -f "$CFG/Kvantum/kvantum.kvconfig" ]; then
    printf '[General]\ntheme=TenshiSTEP-zirconium\n' > "$CFG/Kvantum/kvantum.kvconfig"
  fi
  echo "  - kvantum style -> $CFG/Kvantum/TenshiSTEP-zirconium/ (widgetStyle=kvantum)"
fi

# 5c. GTK theme (so GTK/GNOME apps match the NeXT look under Plasma)
if [ -d "$SRC/gtk/TenshiSTEP-zirconium" ]; then
  install -d "$DATA/themes/TenshiSTEP-zirconium"
  cp -R "$SRC/gtk/TenshiSTEP-zirconium/"* "$DATA/themes/TenshiSTEP-zirconium/"
  echo "  - gtk theme     -> $DATA/themes/TenshiSTEP-zirconium/ (apply via kde-gtk-config, or"
  echo "                     gsettings set org.gnome.desktop.interface gtk-theme TenshiSTEP-zirconium)"
fi

# 5d. Wallpaper package (selectable in Desktop -> Wallpaper)
if [ -d "$SRC/wallpaper/TenshiSTEP-zirconium" ]; then
  install -d "$DATA/wallpapers"
  rm -rf "$DATA/wallpapers/TenshiSTEP-zirconium"
  cp -R "$SRC/wallpaper/TenshiSTEP-zirconium" "$DATA/wallpapers/TenshiSTEP-zirconium"
  echo "  - wallpaper     -> $DATA/wallpapers/TenshiSTEP-zirconium/ (Desktop -> Wallpaper)"
fi

# 6. Look-and-Feel (Global Theme: ties colours/icons/decoration/splash together)
install -d "$DATA/plasma/look-and-feel"
rm -rf "$DATA/plasma/look-and-feel/org.tenshistep.zirconium.desktop"
cp -R "$SRC/plasma/look-and-feel/org.tenshistep.zirconium.desktop" "$DATA/plasma/look-and-feel/org.tenshistep.zirconium.desktop"
echo "  - global theme  -> $DATA/plasma/look-and-feel/org.tenshistep.zirconium.desktop/"

# 6-style. Point the Global Theme's widgetStyle at the best style actually
# present on THIS system (kvantum / compiled TenshiSTEP QStyle), else keep
# Breeze so applying the theme never yields an unstyled/broken look.
LNF_DEFAULTS="$DATA/plasma/look-and-feel/org.tenshistep.zirconium.desktop/contents/defaults"
WSTYLE=Breeze
# Prefer the bespoke compiled TenshiSTEP-zirconium QStyle when its plugin is
# installed; fall back to the Kvantum engine, then Breeze.
if [ -n "$(find /usr/lib /usr/lib64 /usr/lib/*-linux-gnu -maxdepth 6 \
             -path '*plugins/styles*' -iname 'libtenshistepzirconiumstyle.so' 2>/dev/null | head -n1)" ]; then
  WSTYLE=TenshiSTEP-zirconium
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
if [ -d "$SRC/plasma/kwin/tabbox/org.tenshistep.zirconium.switcher" ]; then
  install -d "$DATA/kwin/tabbox"
  rm -rf "$DATA/kwin/tabbox/org.tenshistep.zirconium.switcher"
  cp -R "$SRC/plasma/kwin/tabbox/org.tenshistep.zirconium.switcher" "$DATA/kwin/tabbox/org.tenshistep.zirconium.switcher"
  echo "  - alt-tab switch-> $DATA/kwin/tabbox/org.tenshistep.zirconium.switcher/"
fi

# 6c. Lock screen (NeXT unlock box). Plasma 6 loads the lock screen ONLY from the
#     desktop shell package -- NOT from a Global Theme/look-and-feel -- so it has
#     to be installed there, which needs root. The distro original is backed up as
#     *.tenshistep-orig (once); revert instructions are printed at the end. Without
#     root this step is skipped with instructions rather than failing the install.
LOCK_SRC="$SRC/lockscreen"
SHELL_LOCK="/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen"
if [ -d "$LOCK_SRC" ] && [ -d "$SHELL_LOCK" ]; then
  _sudo=""
  if [ "$(id -u)" -eq 0 ]; then :
  elif sudo -n true 2>/dev/null; then _sudo="sudo"
  elif [ -t 0 ] && sudo -v 2>/dev/null; then _sudo="sudo"
  fi
  if [ "$(id -u)" -eq 0 ] || [ -n "$_sudo" ]; then
    if $_sudo test ! -f "$SHELL_LOCK/LockScreenUi.qml.tenshistep-orig"; then
      $_sudo cp -a "$SHELL_LOCK/LockScreenUi.qml" "$SHELL_LOCK/LockScreenUi.qml.tenshistep-orig" || true
    fi
    if $_sudo cp "$LOCK_SRC/LockScreenUi.qml" "$SHELL_LOCK/LockScreenUi.qml" \
       && $_sudo rm -rf "$SHELL_LOCK/nextui" \
       && $_sudo cp -R "$LOCK_SRC/nextui" "$SHELL_LOCK/nextui"; then
      echo "  - lock screen   -> $SHELL_LOCK/ (NeXT unlock box; original backed up)"
    else
      echo "  !! LOCK SCREEN install failed (could not write $SHELL_LOCK)." >&2
    fi
  else
    echo "  -- lock screen  -> skipped (needs root). To install the NeXT lock screen:" >&2
    echo "       sudo cp '$LOCK_SRC/LockScreenUi.qml' '$SHELL_LOCK/'" >&2
    echo "       sudo cp -R '$LOCK_SRC/nextui' '$SHELL_LOCK/'" >&2
  fi
fi

cat <<'EOF'

Done. Now apply it:

  Color scheme:
    System Settings -> Colors -> "TenshiSTEP-zirconium"
    (or:  plasma-apply-colorscheme TenshiSTEP-zirconium)

  Window decoration:
    System Settings -> Window Decorations -> "TenshiSTEP-zirconium"

  Konsole:
    Konsole -> Settings -> Edit Profile -> Appearance -> "TenshiSTEP-zirconium"

  Icon theme:
    System Settings -> Icons -> "TenshiSTEP-zirconium"
    (or:  plasma-changeicons TenshiSTEP-zirconium)

  Plasma style (widgets):
    System Settings -> Plasma Style -> "TenshiSTEP-zirconium"
    (or:  plasma-apply-desktoptheme TenshiSTEP-zirconium)

  Everything at once (Global Theme):
    System Settings -> Global Theme -> "TenshiSTEP-zirconium"
    (or:  lookandfeeltool -a org.tenshistep.zirconium.desktop)
    To revert:  lookandfeeltool -a org.kde.breeze.desktop

  Lock screen (NeXT unlock box):
    Installed into the desktop shell package (Plasma 6 loads the lock screen only
    from there, not from a Global Theme). It is active on the next lock -- test
    with Meta+L. To revert to the stock lock screen:
      L=/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen
      sudo cp "$L/LockScreenUi.qml.tenshistep-orig" "$L/LockScreenUi.qml"
      sudo rm -rf "$L/nextui"

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
