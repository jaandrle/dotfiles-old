export GREP_COLOR="1;32"
export EDITOR="vim"
export SUDO_EDITOR="vim"
export VISUAL="vim"

[[ -f /etc/bashrc ]] && . /etc/bashrc		# Source global definitions
[[ $- != *i* ]] && return					# If not running interactively, don't do anything

export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend cmdhist
shopt -s histverify
export HISTSIZE=1000
export HISTFILESIZE=2000

set -o vi
bind -m vi-command 'Control-l: clear-screen'
bind -m vi-insert 'Control-l: clear-screen'

export MANPAGER="/bin/sh -c \"col -b | vim --not-a-term -c 'set ft=man ts=8 nomod nolist noma' -\""
export LS_COLORS=$LS_COLORS:'tw=01;04;34:ow=01;04;34:'

alias myip='curl -s -m 5 https://ipleak.net/json/'
alias q='exit'
 	if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
fi
alias mls='ls -pQFhA --group-directories-first'
alias mrm='rm -vi'
alias mcp='cp -vi'
alias mmv='mv -vi'
alias mdf='df -Th'
alias mless='less -R -S'
mlsl(){ mls. -l $* --color=always | mless; }

mup(){ cd $(eval printf '../'%.0s {1..$1}); }
