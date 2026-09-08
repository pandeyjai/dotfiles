#!/bin/bash
killall -q polybar 2>/dev/null || true
while pgrep -u "$UID" -x polybar >/dev/null 2>&1; do sleep 0.2; done
sleep 0.5
if command -v xrandr >/dev/null 2>&1; then
  # deduplicate by geometry — mirrored outputs share same +X+Y, keep one bar
  declare -A seen
  MONS=()
  while IFS= read -r line; do
    out=$(echo "$line" | awk '{print $1}')
    geom=$(echo "$line" | grep -o "[0-9]\+x[0-9]\++[0-9]\++[0-9]\+" | head -1)
    [ -z "$geom" ] && continue
    if [[ -z "${seen[$geom]}" ]]; then
      seen[$geom]=1
      MONS+=("$out")
    fi
  done < <(xrandr --query | grep " connected" | grep -E "[0-9]+x[0-9]+\+[0-9]+\+[0-9]+")
  [ ${#MONS[@]} -eq 0 ] && MONS=($(xrandr --query | grep " connected" | awk '{print $1}'))
  for m in "${MONS[@]}"; do MONITOR="$m" polybar --reload bar >/dev/null 2>&1 & done
else
  polybar --reload bar >/dev/null 2>&1 &
fi
