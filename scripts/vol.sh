#!/bin/bash
case "$1" in
  up) pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
  down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
  mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
esac
vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o "[0-9]*%" | head -1 | tr -d '%')
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -qi yes && echo " (muted)" || echo "")
dunstify -a volume -h int:value:"$vol" "volume $vol%$muted"
