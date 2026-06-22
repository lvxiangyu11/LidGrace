#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_ID="$(id -u)"
AGENT="$HOME/Library/LaunchAgents/com.local.lidgrace.app.plist"
DAEMON="/Library/LaunchDaemons/com.local.lidgrace.plist"
SHARED="/Library/Application Support/LidGrace"

"$ROOT/Scripts/clean_all_old.sh"
"$ROOT/Scripts/build.sh"

sudo mkdir -p /usr/local/sbin
sudo mkdir -p "$SHARED"
sudo chmod 777 "$SHARED"

sudo cp -R "$ROOT/Build/LidGrace.app" /Applications/LidGrace.app
sudo cp "$ROOT/Build/lidgraced" /usr/local/sbin/lidgraced
sudo chmod 755 /usr/local/sbin/lidgraced

if [[ ! -f "$SHARED/config.json" ]]; then
  sudo tee "$SHARED/config.json" >/dev/null <<'JSON'
{
  "enabled": true,
  "grace_seconds": 300,
  "trigger_on_lid": true,
  "trigger_on_display_sleep": true,
  "trigger_on_screen_lock": true,
  "lock_on_trigger": true
}
JSON
fi

sudo chmod 666 "$SHARED/config.json"
sudo chmod 777 "$SHARED"

sudo tee "$DAEMON" >/dev/null <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.local.lidgrace</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>/usr/local/sbin/lidgraced</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <true/>

  <key>StandardOutPath</key>
  <string>/var/log/lidgrace.daemon.log</string>

  <key>StandardErrorPath</key>
  <string>/var/log/lidgrace.daemon.err</string>
</dict>
</plist>
PLIST

sudo chown root:wheel "$DAEMON"
sudo chmod 644 "$DAEMON"
plutil -lint "$DAEMON"

mkdir -p "$HOME/Library/LaunchAgents"

cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.local.lidgrace.app</string>

  <key>ProgramArguments</key>
  <array>
    <string>/Applications/LidGrace.app/Contents/MacOS/LidGrace</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <true/>

  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/lidgrace.app.log</string>

  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/lidgrace.app.err</string>
</dict>
</plist>
PLIST

chmod 644 "$AGENT"
plutil -lint "$AGENT"

sudo launchctl bootstrap system "$DAEMON" || {
  echo "Daemon bootstrap failed."
  echo "Diagnostics:"
  sudo launchctl print system/com.local.lidgrace || true
  tail -n 50 /var/log/lidgrace.daemon.err 2>/dev/null || true
  exit 1
}

sudo launchctl enable system/com.local.lidgrace
sudo launchctl kickstart -k system/com.local.lidgrace

launchctl bootstrap "gui/$USER_ID" "$AGENT" || {
  echo "App agent bootstrap failed."
  launchctl print "gui/$USER_ID/com.local.lidgrace.app" || true
  tail -n 50 "$HOME/Library/Logs/lidgrace.app.err" 2>/dev/null || true
  exit 1
}

launchctl enable "gui/$USER_ID/com.local.lidgrace.app"
launchctl kickstart -k "gui/$USER_ID/com.local.lidgrace.app"

open -a LidGrace || true

echo "Installed LidGrace."
