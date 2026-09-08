#!/bin/bash
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/display-menu"
mkdir -p "$CACHE_DIR" 2>/dev/null || true
LAYOUT_FILE="$CACHE_DIR/layout"
GPU_FILE="$CACHE_DIR/gpu"
cur_layout=$(cat "$LAYOUT_FILE" 2>/dev/null || echo "")
cur_gpu=$(cat "$GPU_FILE" 2>/dev/null || echo "")
MENU=""
for item in "auto (all on, best res)" "mirror (same image on all)" "extend right" "extend left" "laptop only" "external only" "open arandr (gui)"; do
  key=$(echo "$item" | cut -d'(' -f1 | xargs | tr 'A-Z' 'a-z')
  if [ -n "$cur_layout" ] && [ "$key" = "$cur_layout" ]; then MENU="${MENU}▶ $item\n"
  else MENU="${MENU}  $item\n"; fi
done
for g in "display: cpu (intel)" "display: gpu (nvidia)"; do
  key=$(echo "$g" | grep -o "(.*)" | tr -d "()" | tr 'A-Z' 'a-z')
  if [ -n "$cur_gpu" ] && [ "$key" = "$cur_gpu" ]; then MENU="${MENU}▶ $g\n"
  else MENU="${MENU}  $g\n"; fi
done
CHOICE=$(printf "$MENU" | rofi -dmenu -i -location 3 -width 28 -yoffset 34 -xoffset -12 -theme-str 'window {width: 28%;} inputbar {enabled:false;} prompt {enabled:false;} entry {enabled:false;} element {padding:2px;} listview {lines:9;}' 2>/dev/null | tr 'A-Z' 'a-z' | sed 's/^▶ *//; s/^ *//')
[ -z "$CHOICE" ] && exit 0
XR=$(xrandr --query 2>/dev/null)
INTERNAL=$(echo "$XR" | grep " connected" | grep -E "eDP|LVDS" | awk '{print $1}' | head -1)
ALL_CONNECTED=$(echo "$XR" | grep " connected" | awk '{print $1}')
EXTERNALS=$(echo "$ALL_CONNECTED" | grep -v -E "^eDP|^LVDS" || true)
EXT1=$(echo "$EXTERNALS" | head -1)
[ -z "$INTERNAL" ] && INTERNAL=$(echo "$ALL_CONNECTED" | head -1)
refresh_ui() { ~/.config/polybar/launch.sh >/dev/null 2>&1 & true; ~/.fehbg >/dev/null 2>&1 || feh --bg-fill ~/Pictures/Wallpapers/1182325.jpg >/dev/null 2>&1 || true; }
if echo "$CHOICE" | grep -q "^display:"; then
  GPU=$(echo "$CHOICE" | grep -o "(.*)" | tr -d "()" | tr 'A-Z' 'a-z')
  case "$GPU" in intel) powerprofilesctl set power-saver 2>/dev/null || true ;; *) powerprofilesctl set performance 2>/dev/null || true ;; esac
  echo "$GPU" > "$GPU_FILE" 2>/dev/null || true
  refresh_ui; exit 0
fi
CHOICE1=$(echo "$CHOICE" | cut -d' ' -f1)
case "$CHOICE1" in
  auto) xrandr --auto; ~/.local/bin/fix-interlaced.sh 2>/dev/null || true ;;
  mirror) for out in $EXTERNALS; do xrandr --output "$out" --auto --same-as "$INTERNAL" 2>/dev/null || true; done ;;
  extend)
    # direction from full choice (extend right/left already in menu)
    if echo "$CHOICE" | grep -q "left"; then xrandr --output "$INTERNAL" --auto --primary --output "$EXT1" --auto --left-of "$INTERNAL" 2>/dev/null || true
    else xrandr --output "$INTERNAL" --auto --primary --output "$EXT1" --auto --right-of "$INTERNAL" 2>/dev/null || true; fi ;;
  laptop) for out in $EXTERNALS; do xrandr --output "$out" --off 2>/dev/null || true; done; xrandr --output "$INTERNAL" --auto --primary 2>/dev/null || true ;;
  external) xrandr --output "$EXT1" --auto --primary 2>/dev/null || true; for out in $EXTERNALS; do [ "$out" != "$EXT1" ] && xrandr --output "$out" --auto --right-of "$EXT1" 2>/dev/null || true; done; xrandr --output "$INTERNAL" --off 2>/dev/null || true ;;
  open) arandr 2>/dev/null || true; exit 0 ;;
  *) exit 0 ;;
esac
echo "$CHOICE" | cut -d'(' -f1 | xargs > "$LAYOUT_FILE" 2>/dev/null || true
refresh_ui
