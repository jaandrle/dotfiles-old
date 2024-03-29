export GREP_COLOR="1;32"
export EDITOR="vim"
export SUDO_EDITOR="vim"
export VISUAL="vim"

[[ -f /etc/bashrc ]] && . /etc/bashrc		# Source global definitions
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
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
alias myls='ls -pQFhA --group-directories-first'
alias myrm='rm -vi'
alias mycp='cp -vi'
alias mymv='mv -vi'
alias mydf='df -Th'
alias myless='less -R -S'
mylsl(){ mls -l $* --color=always | mless; }

myup(){ cd $(eval printf '../'%.0s {1..$1}); }
mkcd(){ mkdir -p "${1:?}" && cd "${1}"; }
update(){ ~/update.sh && mv ~/update_new.sh ~/update.sh; }
myping(){ # Pings ip address of noip.com and www.google.com.
  ping -c 1 -q 8.23.224.107 | grep --color=never -A 1 -i '\---'
  ping -c 1 -q www.google.com | grep --color=never -A 1 -i '\---'
}
pushd(){ builtin pushd "$@" >/dev/null && dirs -v; }
popd() { builtin popd "$@" >/dev/null  && dirs -v; }

LAST_PWD_PATH="$(dirname "${BASH_SOURCE[0]}")/.bash_last_pwd"
[ -f "$LAST_PWD_PATH" ] && OLDPWD=`cat $LAST_PWD_PATH`
cd(){ builtin cd "$@" && echo `pwd` > "$LAST_PWD_PATH"; }
