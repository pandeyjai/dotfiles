# ~/.bashrc
[[ $- != *i* ]] && return
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lav'
PS1='[\u@\h \W]\$ '
[[ -d ~/.local/bin ]] && export PATH="$HOME/.local/bin:$PATH"
HISTSIZE=5000
HISTFILESIZE=10000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend 2>/dev/null || true
command -v fastfetch >/dev/null 2>&1 && fastfetch
