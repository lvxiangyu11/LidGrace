#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/Build"
APP="$BUILD/LidGrace.app"
APP_CONTENTS="$APP/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"

SDK="$(xcrun --sdk macosx --show-sdk-path)"
MIN_VERSION="13.0"

rm -rf "$BUILD"
mkdir -p "$APP_MACOS"

cat > "$APP_CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>LidGrace</string>
  <key>CFBundleIdentifier</key>
  <string>com.local.LidGrace</string>
  <key>CFBundleName</key>
  <string>LidGrace</string>
  <key>CFBundleDisplayName</key>
  <string>LidGrace</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

APP_SOURCES=(
  "$ROOT/Sources/LidGraceApp/main.m"
  "$ROOT/Sources/LidGraceApp/AppDelegate.m"
  "$ROOT/Sources/LidGraceApp/AppConfig.m"
  "$ROOT/Sources/LidGraceApp/SharedPaths.m"
  "$ROOT/Sources/LidGraceApp/StatusReader.m"
  "$ROOT/Sources/LidGraceApp/LockScreenService.m"
  "$ROOT/Sources/LidGraceApp/SettingsWindowController.m"
  "$ROOT/Sources/LidGraceApp/StatusMenuController.m"
)

clang -fobjc-arc \
  -isysroot "$SDK" \
  -mmacosx-version-min="$MIN_VERSION" \
  -framework Cocoa \
  -framework Foundation \
  "${APP_SOURCES[@]}" \
  -o "$APP_MACOS/LidGrace"

cp "$ROOT/Sources/LidGraceDaemon/lidgraced.zsh" "$BUILD/lidgraced"
chmod 755 "$APP_MACOS/LidGrace" "$BUILD/lidgraced"

echo "Built: $APP"
echo "Built: $BUILD/lidgraced"
