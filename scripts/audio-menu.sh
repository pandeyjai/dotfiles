#!/bin/bash
set -e
get_sink() { pactl get-default-sink 2>/dev/null || pactl info 2>/dev/null | awk -F': ' '/Default Sink/{print $2}'; }
get_src()  { pactl get-default-source 2>/dev/null || pactl info 2>/dev/null | awk -F': ' '/Default Source/{print $2}'; }
CUR_SINK=$(get_sink)
CUR_SRC=$(get_src)

flat_list() {
  pactl list sinks 2>/dev/null | awk '
    /Name: /{n=$2}
    /Description: /{d=substr($0,index($0,$2)); printf "%s|%s\n", n, d}
  ' | while IFS='|' read -r name desc; do
    mark=" "; [ "$name" = "$CUR_SINK" ] && mark="▶"
    printf "%s output: %s\n" "$mark" "$(echo "$desc" | tr 'A-Z' 'a-z')"
  done
  pactl list sources 2>/dev/null | awk '
    /Name: /{n=$2}
    /Description: /{d=substr($0,index($0,$2)); if (n !~ /\.monitor$/) printf "%s|%s\n", n, d}
  ' | while IFS='|' read -r name desc; do
    mark=" "; [ "$name" = "$CUR_SRC" ] && mark="▶"
    printf "%s input: %s\n" "$mark" "$(echo "$desc" | tr 'A-Z' 'a-z')"
  done
}

move_all(){ pactl list sink-inputs short 2>/dev/null | awk '{print $1}' | while read -r i; do pactl move-sink-input "$i" "$1" 2>/dev/null || true; done; }

vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o "[0-9]*%" | head -1); [ -z "$vol" ] && vol="?"
MENU="$(flat_list)"
[ -z "$MENU" ] && exit 0
COUNT=$(echo "$MENU" | wc -l)
[ "$COUNT" -gt 8 ] && COUNT=8
[ "$COUNT" -lt 2 ] && COUNT=2

# still anchored top-right, no search/prompt, compact but wide enough for names
ROFI="rofi -dmenu -i -location 3 -width 32 -lines $COUNT -yoffset 34 -xoffset -12 -mesg \"volume $vol\" -theme-str 'window {width: 32%;} prompt {enabled:false;} entry {enabled:false;} textbox-prompt-colon {enabled:false;} overlay {enabled:false;} num-filtered-rows {enabled:false;} textbox-num-sep {enabled:false;} num-rows {enabled:false;} case-indicator {enabled:false;} element {padding:1px;} listview {lines:$COUNT;} textbox {wrap:true;}'"

CHOICE=$(echo "$MENU" | eval "$ROFI" ) || exit 0
[ -z "$CHOICE" ] && exit 0

CLEAN=$(echo "$CHOICE" | sed 's/^▶ *//; s/^ *//')
DESC=$(echo "$CLEAN" | sed 's/^output: //; s/^input: //')

if echo "$CLEAN" | grep -q "^output:"; then
  # map description back to full name
  NAME=$(pactl list sinks 2>/dev/null | awk -v d="$DESC" '
    /Name: /{n=$2}
    /Description: /{desc=substr($0,index($0,$2)); if(desc==d) print n}
  ' | head -1)
  [ -z "$NAME" ] && NAME=$(pactl list sinks 2>/dev/null | awk -v d="$DESC" 'BEGIN{IGNORECASE=1} /Description: /{desc=substr($0,index($0,$2)); if(tolower(desc)==tolower(d)) print n}' | head -1)
  [ -n "$NAME" ] && pactl set-default-sink "$NAME" && move_all "$NAME"
elif echo "$CLEAN" | grep -q "^input:"; then
  NAME=$(pactl list sources 2>/dev/null | awk -v d="$DESC" '
    /Name: /{n=$2}
    /Description: /{desc=substr($0,index($0,$2)); if(n !~ /\.monitor$/ && desc==d) print n}
  ' | head -1)
  [ -z "$NAME" ] && NAME=$(pactl list sources 2>/dev/null | awk -v d="$DESC" 'BEGIN{IGNORECASE=1} /Description: /{desc=substr($0,index($0,$2)); if(n !~ /\.monitor$/ && tolower(desc)==tolower(d)) print n}' | head -1)
  [ -n "$NAME" ] && pactl set-default-source "$NAME"
fi
