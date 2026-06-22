#!/usr/bin/env bash
set -euo pipefail

LABELS=(
  "com.local.lid-lock-sleep-after-5m"
  "com.local.lidgrace"
  "com.local.LidGraceDaemon"
  "com.local.lidgrace.daemon"
)

APP_LABELS=(
  "com.local.lidgrace.app"
  "com.local.LidGraceApp"
)

USER_ID="$(id -u)"

echo "Stopping old LidGrace services..."

for label in "${LABELS[@]}"; do
  sudo launchctl bootout "system/$label" >/dev/null 2>&1 || true
  sudo launchctl disable "system/$label" >/dev/null 2>&1 || true
done

for label in "${APP_LABELS[@]}"; do
  launchctl bootout "gui/$USER_ID/$label" >/dev/null 2>&1 || true
  launchctl disable "gui/$USER_ID/$label" >/dev/null 2>&1 || true
done

echo "Removing old files..."

sudo rm -f /Library/LaunchDaemons/com.local.lid-lock-sleep-after-5m.plist
sudo rm -f /Library/LaunchDaemons/com.local.lidgrace.plist
sudo rm -f /Library/LaunchDaemons/com.local.LidGraceDaemon.plist
sudo rm -f /Library/LaunchDaemons/com.local.lidgrace.daemon.plist

rm -f "$HOME/Library/LaunchAgents/com.local.lidgrace.app.plist"
rm -f "$HOME/Library/LaunchAgents/com.local.LidGraceApp.plist"
sudo rm -f /Library/LaunchAgents/com.local.lidgrace.app.plist
sudo rm -f /Library/LaunchAgents/com.local.LidGraceApp.plist

sudo rm -f /usr/local/sbin/lidgraced
sudo rm -f /usr/local/sbin/lid-lock-sleep-after-5m.zsh
sudo rm -rf /Applications/LidGrace.app
sudo rm -rf "/Library/Application Support/LidGrace"
sudo rm -rf /Users/Shared/LidGrace
sudo rm -f /var/tmp/lid_lock_sleep_after_5m_since
sudo rm -f /var/log/lidgrace.daemon.log /var/log/lidgrace.daemon.err
sudo rm -f /var/log/lid-lock-sleep-after-5m.log /var/log/lid-lock-sleep-after-5m.err
rm -f "$HOME"/Library/Logs/lidgrace.app.*

sudo pmset -a disablesleep 0 >/dev/null 2>&1 || true

echo "Old LidGrace builds and services cleaned."
