#!/usr/bin/env bash
set -euo pipefail

USER_ID="$(id -u)"

launchctl bootout "gui/$USER_ID/com.local.lidgrace.app" >/dev/null 2>&1 || true
sudo launchctl bootout "system/com.local.lidgrace" >/dev/null 2>&1 || true

rm -f "$HOME/Library/LaunchAgents/com.local.lidgrace.app.plist"
sudo rm -f /Library/LaunchDaemons/com.local.lidgrace.plist
sudo rm -rf /Applications/LidGrace.app
sudo rm -f /usr/local/sbin/lidgraced
sudo rm -rf "/Library/Application Support/LidGrace"
sudo rm -f /var/log/lidgrace.daemon.log /var/log/lidgrace.daemon.err
rm -f "$HOME/Library/Logs/lidgrace.app.log" "$HOME/Library/Logs/lidgrace.app.err"

sudo pmset -a disablesleep 0 >/dev/null 2>&1 || true

echo "Uninstalled LidGrace."
