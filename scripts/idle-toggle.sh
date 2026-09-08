#!/bin/bash
STATE_FILE="/tmp/polybar-idle-inhibit"
PID_FILE="/tmp/polybar-idle-inhibit.pid"

is_on() { [ -f "$STATE_FILE" ]; }

status() {
  if is_on; then echo "%{F#565f89}awake%{F-}"; else echo "%{F#c0caf5}idle%{F-}"; fi
}
toggle() {
  if is_on; then
    rm -f "$STATE_FILE"
    [ -f "$PID_FILE" ] && kill "$(cat "$PID_FILE")" 2>/dev/null || true; rm -f "$PID_FILE"
    xset s on 2>/dev/null; xset s 600 2>/dev/null; xset +dpms 2>/dev/null; xset dpms 600 600 600 2>/dev/null
    notify-send "idle" "screen can sleep after 10 min" 2>/dev/null || true
  else
    touch "$STATE_FILE"
    xset s off 2>/dev/null; xset -dpms 2>/dev/null
    systemd-inhibit --what=idle:sleep --who=polybar --why="keep awake (clicked)" sleep infinity & echo $! > "$PID_FILE"
    notify-send "awake" "screen stays on (click again to allow sleep)" 2>/dev/null || true
  fi
}
case "$1" in
  toggle) toggle ;;
  *) status ;;
esac
