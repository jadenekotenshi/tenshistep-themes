# Package-manager notifier hooks

The TenshiSTEP install script sets up a **systemd user timer** that runs
`tenshistep-update-notifier` every 6 hours — that alone gives themed
"updates available" notifications with the TenshiSTEP icons.

To also fire *immediately after a transaction*, install the matching hook
(these are **system-wide** and need root):

- **Arch / pacman:** copy `50-tenshistep-notify.hook` to `/etc/pacman.d/hooks/`.
- **Debian / apt:** copy `99tenshistep-notify` to `/etc/apt/apt.conf.d/`.
- **Fedora / dnf:** enable `dnf-automatic` (`--downloadonly`) and add a
  `--setopt` post-hook, or add a drop-in that runs:
  `systemctl --user -M <user>@ start tenshistep-update-notifier.service`.

Each hook just starts the user's `tenshistep-update-notifier.service` for every
logged-in session, so the notification appears in that user's tray.
