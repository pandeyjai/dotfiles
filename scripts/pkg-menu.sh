#!/bin/bash
set -e
have() { command -v "$1" >/dev/null 2>&1; }
lower() { tr 'A-Z' 'a-z'; }
run_in_kitty() {
  kitty -e bash -c "$1; echo; read -p 'press enter to close...'" &
}
MAIN="install package (official)
install package (aur)
remove package
update system"
CHOICE=$(printf "%s\n" "$MAIN" | lower | rofi -dmenu -i -location 3 -width 22 -yoffset 34 -xoffset -12 -theme-str 'window {width: 22%;} inputbar {enabled:false;} prompt {enabled:false;} entry {enabled:false;} textbox-prompt-colon {enabled:false;} overlay {enabled:false;} num-filtered-rows {enabled:false;} textbox-num-sep {enabled:false;} num-rows {enabled:false;} case-indicator {enabled:false;} element {padding:4px;} listview {lines:4;} textbox {wrap:true;}' 2>/dev/null || echo "")
[ -z "$CHOICE" ] && exit 0
case "$CHOICE" in
  "install package (official)")
    PKG=$(pacman -Slq 2>/dev/null | lower | rofi -dmenu -i -location 3 -width 30 -yoffset 34 -xoffset -12 -theme-str 'window {width: 30%;} inputbar {enabled:false;} prompt {enabled:false;} entry {enabled:false;} textbox-prompt-colon {enabled:false;} overlay {enabled:false;} num-filtered-rows {enabled:false;} textbox-num-sep {enabled:false;} num-rows {enabled:false;} case-indicator {enabled:false;} element {padding:2px;} listview {lines:8;} textbox {wrap:true;}' 2>/dev/null | tr 'A-Z' 'a-z' || true)
    [ -z "$PKG" ] && exit 0
    PKG=$(echo "$PKG" | awk '{print $1}' | lower)
    if ! pacman -Si "$PKG" >/dev/null 2>&1; then real=$(pacman -Slq 2>/dev/null | grep -i "^$PKG$" | head -1); [ -n "$real" ] && PKG="$real"; fi
    run_in_kitty "sudo pacman -S --needed $PKG"
    ;;
  "install package (aur)")
    if ! have yay; then notify-send "yay not installed" 2>/dev/null || echo "yay missing"; exit 0; fi
    PKG=$(yay -Slq 2>/dev/null | lower | rofi -dmenu -i -location 3 -width 30 -yoffset 34 -xoffset -12 -theme-str 'window {width: 30%;} inputbar {enabled:false;} prompt {enabled:false;} entry {enabled:false;} textbox-prompt-colon {enabled:false;} overlay {enabled:false;} num-filtered-rows {enabled:false;} textbox-num-sep {enabled:false;} num-rows {enabled:false;} case-indicator {enabled:false;} element {padding:2px;} listview {lines:8;} textbox {wrap:true;}' 2>/dev/null | tr 'A-Z' 'a-z' || true)
    [ -z "$PKG" ] && exit 0
    PKG=$(echo "$PKG" | awk '{print $1}' | lower)
    real=$(yay -Slq 2>/dev/null | grep -i "^$PKG$" | head -1); [ -n "$real" ] && PKG="$real"
    run_in_kitty "yay -S --needed $PKG"
    ;;
  "remove package")
    PKG=$(pacman -Qq 2>/dev/null | lower | rofi -dmenu -i -location 3 -width 30 -yoffset 34 -xoffset -12 -theme-str 'window {width: 30%;} inputbar {enabled:false;} prompt {enabled:false;} entry {enabled:false;} textbox-prompt-colon {enabled:false;} overlay {enabled:false;} num-filtered-rows {enabled:false;} textbox-num-sep {enabled:false;} num-rows {enabled:false;} case-indicator {enabled:false;} element {padding:2px;} listview {lines:8;} textbox {wrap:true;}' 2>/dev/null | tr 'A-Z' 'a-z' || true)
    [ -z "$PKG" ] && exit 0
    PKG=$(echo "$PKG" | awk '{print $1}' | lower)
    real=$(pacman -Qq 2>/dev/null | grep -i "^$PKG$" | head -1); [ -n "$real" ] && PKG="$real"
    run_in_kitty "sudo pacman -Rns $PKG"
    ;;
  "update system")
    run_in_kitty "sudo pacman -Syu"
    ;;
esac
