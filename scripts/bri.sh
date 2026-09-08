#!/bin/bash
LOG="/tmp/bri.log"
echo "$(date '+%F %T') bri.sh $1 DISPLAY=$DISPLAY" >> "$LOG"

# 1. Hardware backlight (always try if intel_backlight exists)
if [ -d /sys/class/backlight/intel_backlight ] || brightnessctl -m >/dev/null 2>&1; then
  case "$1" in
    up) out=$(brightnessctl set +5% 2>&1) ;; 
    down) out=$(brightnessctl set 5%- 2>&1) ;;
  esac
  echo "$out" >> "$LOG" 2>&1
fi

# 2. External monitors (software xrandr) - only for connected non-eDP
connected=$(xrandr --query 2>/dev/null | grep " connected" | awk '{print $1}')
for out in $connected; do
  echo "$out" | grep -qi "eDP" && continue
  cur=$(xrandr --verbose 2>/dev/null | awk -v o="$out" '$1==o{getline; while($1!="Brightness:"){getline} print $2}' | head -1)
  [ -z "$cur" ] && cur=1.0
  cur_p=$(awk "BEGIN{print int($cur*100)}")
  case "$1" in
    up) new_p=$((cur_p + 5)); [ "$new_p" -gt 100 ] && new_p=100; new=$(awk "BEGIN{print $new_p/100}") ;;
    down) new_p=$((cur_p - 5)); [ "$new_p" -lt 10 ] && new_p=10; new=$(awk "BEGIN{print $new_p/100}") ;;
  esac
  xrandr --output "$out" --brightness "$new" 2>/dev/null && echo "xrandr $out $cur -> $new" >> "$LOG" || true
done

# 3. OSD
cur=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -1)
[ -z "$cur" ] && cur=50
dunstify -a brightness -u low -h int:value:"$cur" -h string:x-dunst-stack-tag:brightness "Brightness $cur%" 2>>"$LOG" || true
echo " -> $cur%" >> "$LOG"
