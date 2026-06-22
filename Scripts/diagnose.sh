#!/usr/bin/env bash
set -euo pipefail

echo "== clang =="
xcrun --sdk macosx clang --version || true

echo
echo "== SDK =="
xcrun --sdk macosx --show-sdk-path || true

echo
echo "== launchd daemon =="
sudo launchctl print system/com.local.lidgrace 2>/dev/null | head -80 || true

echo
echo "== launchd app =="
launchctl print "gui/$(id -u)/com.local.lidgrace.app" 2>/dev/null | head -80 || true

echo
echo "== pmset disablesleep =="
pmset -g custom | grep disablesleep || true

echo
echo "== shared files =="
ls -la "/Library/Application Support/LidGrace" 2>/dev/null || true

echo
echo "== config =="
cat "/Library/Application Support/LidGrace/config.json" 2>/dev/null || true

echo
echo "== status =="
cat "/Library/Application Support/LidGrace/status.json" 2>/dev/null || true

echo
echo "== lid/display raw state =="
ioreg -r -k AppleClamshellState 2>/dev/null | grep AppleClamshellState || true
ioreg -n IODisplayWrangler -r -d 1 2>/dev/null | grep CurrentPowerState || true

echo
echo "== daemon logs =="
tail -n 80 /var/log/lidgrace.daemon.log 2>/dev/null || true
tail -n 80 /var/log/lidgrace.daemon.err 2>/dev/null || true

echo
echo "== app logs =="
tail -n 80 "$HOME/Library/Logs/lidgrace.app.log" 2>/dev/null || true
tail -n 80 "$HOME/Library/Logs/lidgrace.app.err" 2>/dev/null || true
