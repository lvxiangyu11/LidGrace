#!/bin/zsh
set -u

SHARED="/Library/Application Support/LidGrace"
CONFIG="$SHARED/config.json"
STATUS="$SHARED/status.json"
STATE="$SHARED/state_since"
MANUAL_TRIGGER="$SHARED/manual_trigger"
LOCK_REQUEST="$SHARED/lock_request"

INTERVAL=5
DEFAULT_GRACE=300

mkdir -p "$SHARED"
chmod 777 "$SHARED" 2>/dev/null || true

write_default_config() {
  cat > "$CONFIG" <<'JSON'
{
  "enabled": true,
  "grace_seconds": 300,
  "trigger_on_lid": true,
  "trigger_on_display_sleep": true,
  "trigger_on_screen_lock": true,
  "lock_on_trigger": true
}
JSON
  chmod 666 "$CONFIG" 2>/dev/null || true
}

json_bool() {
  local key="$1"
  local fallback="$2"
  if [[ ! -f "$CONFIG" ]]; then
    echo "$fallback"
    return
  fi

  local value
  value=$(/usr/bin/awk -v key="\"$key\"" '
    $0 ~ key {
      if ($0 ~ /true/) { print "true"; exit }
      if ($0 ~ /false/) { print "false"; exit }
    }
  ' "$CONFIG")

  if [[ -z "$value" ]]; then
    echo "$fallback"
  else
    echo "$value"
  fi
}

json_int() {
  local key="$1"
  local fallback="$2"
  if [[ ! -f "$CONFIG" ]]; then
    echo "$fallback"
    return
  fi

  local value
  value=$(/usr/bin/awk -v key="\"$key\"" '
    $0 ~ key {
      gsub(/[^0-9]/, " ")
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^[0-9]+$/) { print $i; exit }
      }
    }
  ' "$CONFIG")

  if [[ -z "$value" ]]; then
    echo "$fallback"
  else
    echo "$value"
  fi
}

write_status() {
  local mode="$1"
  local reason="$2"
  local remaining="$3"
  local now
  now=$(/bin/date +%s)

  cat > "$STATUS" <<JSON
{
  "mode": "$mode",
  "reason": "$reason",
  "remaining_seconds": $remaining,
  "updated_at": $now
}
JSON

  chmod 666 "$STATUS" 2>/dev/null || true
}

lid_closed() {
  local state
  state=$(/usr/sbin/ioreg -r -k AppleClamshellState 2>/dev/null | /usr/bin/awk '/AppleClamshellState/ {print $3; exit}')
  [[ "$state" == "Yes" ]]
}

display_sleeping() {
  local state
  state=$(/usr/sbin/ioreg -n IODisplayWrangler -r -d 1 2>/dev/null | /usr/bin/awk -F'= ' '/CurrentPowerState/ {gsub(/ /, "", $2); print $2; exit}')
  [[ -n "$state" && "$state" != "4" ]]
}

request_lock() {
  /usr/bin/touch "$LOCK_REQUEST" 2>/dev/null || true
  chmod 666 "$LOCK_REQUEST" 2>/dev/null || true
}

allow_sleep_now() {
  /usr/bin/pmset -a disablesleep 0 >/dev/null 2>&1 || true
}

prevent_sleep_now() {
  /usr/bin/pmset -a disablesleep 1 >/dev/null 2>&1 || true
}

sleep_machine() {
  allow_sleep_now
  /usr/bin/pmset sleepnow >/dev/null 2>&1 || true
}

if [[ ! -f "$CONFIG" ]]; then
  write_default_config
fi

write_status "starting" "" 0

while true; do
  enabled=$(json_bool "enabled" "true")
  grace=$(json_int "grace_seconds" "$DEFAULT_GRACE")
  trigger_on_lid=$(json_bool "trigger_on_lid" "true")
  trigger_on_display=$(json_bool "trigger_on_display_sleep" "true")
  lock_on_trigger=$(json_bool "lock_on_trigger" "true")

  if [[ "$enabled" != "true" ]]; then
    /bin/rm -f "$STATE" "$MANUAL_TRIGGER" 2>/dev/null || true
    allow_sleep_now
    write_status "disabled" "" 0
    /bin/sleep "$INTERVAL"
    continue
  fi

  prevent_sleep_now

  trigger=0
  reason=""

  if [[ "$trigger_on_lid" == "true" ]] && lid_closed; then
    trigger=1
    reason="lid"
  fi

  if [[ "$trigger_on_display" == "true" ]] && display_sleeping; then
    trigger=1
    if [[ -z "$reason" ]]; then reason="display"; fi
  fi

  if [[ -f "$MANUAL_TRIGGER" ]]; then
    trigger=1
    reason="manual"
    /bin/rm -f "$MANUAL_TRIGGER" 2>/dev/null || true
  fi

  now=$(/bin/date +%s)

  if [[ "$trigger" == "1" && ! -f "$STATE" ]]; then
    echo "$now" > "$STATE"
    chmod 666 "$STATE" 2>/dev/null || true
    if [[ "$lock_on_trigger" == "true" ]]; then
      request_lock
    fi
  fi

  if [[ -f "$STATE" ]]; then
    since=$(/bin/cat "$STATE" 2>/dev/null)
    if [[ -z "$since" ]]; then since="$now"; fi

    elapsed=$(( now - since ))
    remaining=$(( grace - elapsed ))
    if (( remaining < 0 )); then remaining=0; fi

    if (( elapsed >= grace )); then
      write_status "sleeping" "$reason" 0
      /bin/rm -f "$STATE" 2>/dev/null || true
      sleep_machine
      /bin/sleep 20
    else
      write_status "active" "$reason" "$remaining"
    fi
  else
    write_status "idle" "" 0
  fi

  /bin/sleep "$INTERVAL"
done
