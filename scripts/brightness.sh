#!/bin/bash
# polybar brightness display - shows icon + percent, supports scroll
# gets brightness via brightnessctl (hardware) or xrandr fallback
if [ "$1" = "up" ]; then
  ~/.local/bin/bri.sh up >/dev/null 2>&1
  sleep 0.1
elif [ "$1" = "down" ]; then
  ~/.local/bin/bri.sh down >/dev/null 2>&1
  sleep 0.1
fi

# get current brightness
cur=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' | head -1)
if [ -z "$cur" ]; then
  # fallback to xrandr for HDMI
  cur=$(xrandr --verbose 2>/dev/null | grep -A5 "HDMI.* connected" | grep "Brightness:" | awk '{print int($2*100)}' | head -1)
fi
[ -z "$cur" ] && cur=50

# pick icon (Nerd Font + Font Awesome compatible)
if [ "$cur" -ge 80 ]; then icon="󰃠"  # high
elif [ "$cur" -ge 60 ]; then icon="󰃟"
elif [ "$cur" -ge 30 ]; then icon="󰃝"
else icon="󰃞"
fi
# fallback if nerd font not showing, use FA sun:  
# ensure output is one line for polybar
echo "$icon $cur%"
