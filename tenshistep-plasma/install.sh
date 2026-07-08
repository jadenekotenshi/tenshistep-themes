#!/usr/bin/env bash
#
# Installs the TenshiSTEP Plasma theme bundle into the current user's
# ~/.local/share tree. Re-run safely; it overwrites previous copies.
#
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"

echo "Installing TenshiSTEP Plasma theme from: $SRC"
echo "Target data dir: $DATA"

# 1. Color scheme
install -d "$DATA/color-schemes"
install -m 644 "$SRC/color-schemes/TenshiSTEP.colors" "$DATA/color-schemes/TenshiSTEP.colors"
echo "  - color scheme  -> $DATA/color-schemes/TenshiSTEP.colors"

# 2. Aurorae window decoration
install -d "$DATA/aurorae/themes/TenshiSTEP"
install -m 644 "$SRC/aurorae/TenshiSTEP/"* "$DATA/aurorae/themes/TenshiSTEP/"
echo "  - window decor  -> $DATA/aurorae/themes/TenshiSTEP/"

# 3. Konsole color scheme
install -d "$DATA/konsole"
install -m 644 "$SRC/konsole/TenshiSTEP.colorscheme" "$DATA/konsole/TenshiSTEP.colorscheme"
[ -f "$SRC/konsole/TenshiSTEP.profile" ] && \
  install -m 644 "$SRC/konsole/TenshiSTEP.profile" "$DATA/konsole/TenshiSTEP.profile"
echo "  - konsole       -> $DATA/konsole/TenshiSTEP.{colorscheme,profile}"

# 4. Icon theme (cp -R preserves the alias symlinks inside the tree)
install -d "$DATA/icons"
rm -rf "$DATA/icons/TenshiSTEP"
cp -R "$SRC/icons/TenshiSTEP" "$DATA/icons/TenshiSTEP"
echo "  - icon theme    -> $DATA/icons/TenshiSTEP/"
# Refresh the icon cache if the tool is present (not required by KDE).
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -f -t "$DATA/icons/TenshiSTEP" 2>/dev/null || true
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
rm -rf "$DATA/plasma/desktoptheme/TenshiSTEP"
cp -R "$SRC/plasma/desktoptheme/TenshiSTEP" "$DATA/plasma/desktoptheme/TenshiSTEP"
echo "  - plasma style  -> $DATA/plasma/desktoptheme/TenshiSTEP/"

# 5b. Kvantum application style (the chiselled NeXT widget look; needs the
#     Kvantum engine installed for widgetStyle=kvantum to take effect).
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
if [ -d "$SRC/kvantum/TenshiSTEP" ]; then
  install -d "$CFG/Kvantum/TenshiSTEP"
  install -m 644 "$SRC/kvantum/TenshiSTEP/"* "$CFG/Kvantum/TenshiSTEP/"
  # Select TenshiSTEP as the active Kvantum theme without clobbering an existing
  # config: prefer kvantummanager (preserves other keys), else only write fresh.
  if command -v kvantummanager >/dev/null 2>&1; then
    kvantummanager --set TenshiSTEP >/dev/null 2>&1 || true
  elif [ ! -f "$CFG/Kvantum/kvantum.kvconfig" ]; then
    printf '[General]\ntheme=TenshiSTEP\n' > "$CFG/Kvantum/kvantum.kvconfig"
  fi
  echo "  - kvantum style -> $CFG/Kvantum/TenshiSTEP/ (widgetStyle=kvantum)"
fi

# 5c. GTK theme (so GTK/GNOME apps match the NeXT look under Plasma)
if [ -d "$SRC/gtk/TenshiSTEP" ]; then
  install -d "$DATA/themes/TenshiSTEP"
  cp -R "$SRC/gtk/TenshiSTEP/"* "$DATA/themes/TenshiSTEP/"
  echo "  - gtk theme     -> $DATA/themes/TenshiSTEP/ (apply via kde-gtk-config, or"
  echo "                     gsettings set org.gnome.desktop.interface gtk-theme TenshiSTEP)"
fi

# 5d. Wallpaper package (selectable in Desktop -> Wallpaper)
if [ -d "$SRC/wallpaper/TenshiSTEP" ]; then
  install -d "$DATA/wallpapers"
  rm -rf "$DATA/wallpapers/TenshiSTEP"
  cp -R "$SRC/wallpaper/TenshiSTEP" "$DATA/wallpapers/TenshiSTEP"
  echo "  - wallpaper     -> $DATA/wallpapers/TenshiSTEP/ (Desktop -> Wallpaper)"
fi

# 6. Look-and-Feel (Global Theme: ties colours/icons/decoration/splash together)
install -d "$DATA/plasma/look-and-feel"
rm -rf "$DATA/plasma/look-and-feel/org.tenshistep.desktop"
cp -R "$SRC/plasma/look-and-feel/org.tenshistep.desktop" "$DATA/plasma/look-and-feel/org.tenshistep.desktop"
echo "  - global theme  -> $DATA/plasma/look-and-feel/org.tenshistep.desktop/"

# 6-style. Point the Global Theme's widgetStyle at the best style actually
# present on THIS system. The chiselled NeXT widgets need either the Kvantum
# engine or the compiled TenshiSTEP QStyle; if neither is installed we keep
# Breeze so applying the theme never yields an unstyled/broken look.
LNF_DEFAULTS="$DATA/plasma/look-and-feel/org.tenshistep.desktop/contents/defaults"
WSTYLE=Breeze
# Prefer the bespoke compiled TenshiSTEP QStyle when its plugin is installed;
# fall back to the Kvantum engine, then Breeze.
if [ -n "$(find /usr/lib /usr/lib64 /usr/lib/*-linux-gnu -maxdepth 6 \
             -path '*plugins/styles*' -iname 'libtenshistepstyle.so' 2>/dev/null | head -n1)" ]; then
  WSTYLE=TenshiSTEP
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
if [ -d "$SRC/plasma/kwin/tabbox/org.tenshistep.switcher" ]; then
  install -d "$DATA/kwin/tabbox"
  rm -rf "$DATA/kwin/tabbox/org.tenshistep.switcher"
  cp -R "$SRC/plasma/kwin/tabbox/org.tenshistep.switcher" "$DATA/kwin/tabbox/org.tenshistep.switcher"
  echo "  - alt-tab switch-> $DATA/kwin/tabbox/org.tenshistep.switcher/"
fi

# 6b. Updates plasmoid (panel applet)
if [ -d "$SRC/plasma/plasmoids/org.tenshistep.updates" ]; then
  install -d "$DATA/plasma/plasmoids"
  rm -rf "$DATA/plasma/plasmoids/org.tenshistep.updates"
  cp -R "$SRC/plasma/plasmoids/org.tenshistep.updates" "$DATA/plasma/plasmoids/org.tenshistep.updates"
  echo "  - plasmoid      -> $DATA/plasma/plasmoids/org.tenshistep.updates/ (add to a panel)"
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

# 7. Application launchers (.desktop entries for the branded apps)
if compgen -G "$SRC/applications/*.desktop" >/dev/null; then
  install -d "$DATA/applications"
  install -m 644 "$SRC/applications/"*.desktop "$DATA/applications/"
  n=$(ls "$SRC/applications/"*.desktop | wc -l | tr -d ' ')
  echo "  - launchers     -> $DATA/applications/ ($n entries)"
  # Refresh the desktop database so the launchers appear in the app menu.
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DATA/applications" 2>/dev/null || true
  fi
fi

# 8. Package MIME types (so .tardist, FreeBSD/SysV .pkg and Arch packages get icons)
if [ -f "$SRC/mime/packages/tenshistep-packages.xml" ]; then
  install -d "$DATA/mime/packages"
  install -m 644 "$SRC/mime/packages/"*.xml "$DATA/mime/packages/"
  echo "  - mime types    -> $DATA/mime/packages/"
  if command -v update-mime-database >/dev/null 2>&1; then
    update-mime-database "$DATA/mime" 2>/dev/null || true
  fi
fi

# 9. Software-update notifier (systemd user timer using the themed status icons)
if [ -f "$SRC/tools/tenshistep-update-notifier" ]; then
  install -d "$HOME/.local/bin"
  install -m 755 "$SRC/tools/tenshistep-update-notifier" "$HOME/.local/bin/tenshistep-update-notifier"
  install -d "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
  install -m 644 "$SRC/tools/systemd/"*.service "$SRC/tools/systemd/"*.timer \
    "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/"
  echo "  - update notify -> $HOME/.local/bin/tenshistep-update-notifier (+ systemd user timer)"
  if command -v systemctl >/dev/null 2>&1 && [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now tenshistep-update-notifier.timer 2>/dev/null || true
  fi
fi

# 10. KRunner "check for updates" plugin (D-Bus runner; needs python3-dbus + python3-gi)
if [ -f "$SRC/tools/krunner/tenshistep-updates-runner" ]; then
  install -d "$HOME/.local/bin"
  install -m 755 "$SRC/tools/krunner/tenshistep-updates-runner" "$HOME/.local/bin/tenshistep-updates-runner"
  install -d "$DATA/krunner/dbusplugins"
  install -m 644 "$SRC/tools/krunner/plasma-runner-tenshistep-updates.desktop" "$DATA/krunner/dbusplugins/"
  install -d "$DATA/dbus-1/services"
  sed "s|__BIN__|$HOME/.local/bin/tenshistep-updates-runner|" \
    "$SRC/tools/krunner/org.tenshistep.updatesrunner.service.in" \
    > "$DATA/dbus-1/services/org.tenshistep.updatesrunner.service"
  echo "  - krunner       -> $DATA/krunner/dbusplugins/ (type 'updates' in KRunner)"
  if command -v kquitapp6 >/dev/null 2>&1; then kquitapp6 krunner 2>/dev/null || true
  elif command -v kquitapp5 >/dev/null 2>&1; then kquitapp5 krunner 2>/dev/null || true; fi
fi

cat <<'EOF'

Done. Now apply it:

  Color scheme:
    System Settings -> Colors -> "TenshiSTEP"
    (or:  plasma-apply-colorscheme TenshiSTEP)

  Window decoration:
    System Settings -> Window Decorations -> "TenshiSTEP"

  Konsole:
    Konsole -> Settings -> Edit Profile -> Appearance -> "TenshiSTEP"

  Icon theme:
    System Settings -> Icons -> "TenshiSTEP"
    (or:  plasma-changeicons TenshiSTEP)

  Plasma style (widgets):
    System Settings -> Plasma Style -> "TenshiSTEP"
    (or:  plasma-apply-desktoptheme TenshiSTEP)

  Everything at once (Global Theme):
    System Settings -> Global Theme -> "TenshiSTEP"
    (or:  lookandfeeltool -a org.tenshistep.desktop)
    To revert:  lookandfeeltool -a org.kde.breeze.desktop

  Lock screen (NeXT unlock box):
    Installed into the desktop shell package (Plasma 6 loads the lock screen only
    from there, not from a Global Theme). It is active on the next lock -- test
    with Meta+L. To revert to the stock lock screen:
      L=/usr/share/plasma/shells/org.kde.plasma.desktop/contents/lockscreen
      sudo cp "$L/LockScreenUi.qml.tenshistep-orig" "$L/LockScreenUi.qml"
      sudo rm -rf "$L/nextui"

  Application launchers:
    The branded .desktop entries are in the application menu now (adjust each
    Exec= to match how the app is installed on your system, e.g. Flatpak/Snap).
    To remove them:  rm ~/.local/share/applications/{discord,vlc,gimp,...}.desktop

  Software-update notifications:
    A systemd user timer runs tenshistep-update-notifier every 6 hours and shows
    a themed "updates available" notification. Run it now:
      tenshistep-update-notifier
    Check the timer:  systemctl --user status tenshistep-update-notifier.timer
    For instant post-transaction alerts, install a package-manager hook — see
    tools/hooks/README.md (Arch/Debian/Fedora).

  KRunner "check for updates":
    Open KRunner (Alt+Space) and type "updates" to check for / open software
    updates. Needs python3-dbus + python3-gi; if it doesn't appear, enable it in
    System Settings -> Search -> Plasma Search -> "TenshiSTEP Software Updates".

  Updates plasmoid:
    Right-click a panel -> Add Widgets -> "TenshiSTEP Updates" to show the update
    status + count in the panel (click opens Discover).

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
