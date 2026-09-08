#!/bin/bash
cur=$(powerprofilesctl get 2>/dev/null | tr 'A-Z' 'a-z')
[ -z "$cur" ] && cur=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null | tr 'A-Z' 'a-z' | sed 's/powersave/power-saver/; s/schedutil/balanced/')
bat=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null | tr -d '\n'); [ -z "$bat" ] && bat="?"
state=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null | tr 'A-Z' 'a-z'); [ "$state" = "charging" ] && state="(charging)" || state="(discharging)"
list=""; for p in power-saver balanced performance; do [ "$p" = "$cur" ] && list="${list}▶ $p\n" || list="${list}  $p\n"; done
choice=$(printf "$list" | rofi -dmenu -i -location 3 -width 22 -lines 3 -yoffset 34 -xoffset -12 -mesg "battery $bat% $state" -theme-str 'window {width: 22%;} prompt {enabled:false;} entry {enabled:false;} textbox-prompt-colon {enabled:false;} overlay {enabled:false;} num-filtered-rows {enabled:false;} textbox-num-sep {enabled:false;} num-rows {enabled:false;} case-indicator {enabled:false;} element {padding:4px;} listview {lines:3;} textbox {wrap:true;}' 2>/dev/null | sed 's/^▶ *//; s/^ *//' | tr 'A-Z' 'a-z')
[ -z "$choice" ] && exit 0
powerprofilesctl set "$choice" 2>/dev/null || pkexec powerprofilesctl set "$choice"
