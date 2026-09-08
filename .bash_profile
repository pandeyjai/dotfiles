# ~/.bash_profile
[[ -f ~/.bashrc ]] && . ~/.bashrc
[ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && exec startx
