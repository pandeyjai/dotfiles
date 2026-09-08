#!/bin/bash
cap=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo 0)
cap=${cap//[^0-9]/}; [ -z "$cap" ] && cap=0
if [ "$cap" -ge 90 ]; then icon=""
elif [ "$cap" -ge 60 ]; then icon=""
elif [ "$cap" -ge 40 ]; then icon=""
elif [ "$cap" -ge 15 ]; then icon=""
else icon=""; fi
echo "$icon"
