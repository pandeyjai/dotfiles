#!/bin/bash
sleep 0.12
win=$(xdotool getactivewindow 2>/dev/null)
cls=$(xprop -id "$win" WM_CLASS 2>/dev/null | head -1 | tr 'A-Z' 'a-z')
is_term=$(echo "$cls" | grep -qi "kitty\|alacritty\|mate-terminal\|gnome-terminal\|xterm" && echo 1 || echo 0)
if [ "$1" = "copy" ]; then
  if [ "$is_term" = 1 ]; then
    xdotool key --clearmodifiers ctrl+shift+c 2>/dev/null || xclip -o -selection primary 2>/dev/null | xclip -i -selection clipboard 2>/dev/null || true
  else
    xclip -o -selection primary 2>/dev/null | xclip -i -selection clipboard 2>/dev/null || xdotool key --clearmodifiers ctrl+c 2>/dev/null || true
    xdotool key --clearmodifiers ctrl+c 2>/dev/null || true
  fi
else
  if [ "$is_term" = 1 ]; then
    xdotool key --clearmodifiers ctrl+shift+v 2>/dev/null || xdotool key --clearmodifiers shift+Insert 2>/dev/null || xclip -o -selection clipboard 2>/dev/null | xdotool type --clearmodifiers --delay 10 --file - 2>/dev/null || true
  else
    xdotool key --clearmodifiers ctrl+v 2>/dev/null || xclip -o -selection clipboard 2>/dev/null | xdotool type --clearmodifiers --delay 10 --file - 2>/dev/null || true
  fi
fi
