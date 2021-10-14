#### BASH Config file
### Jan Andrle
## Info:
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for examples
[ -f ~/.bash_aliases ] && . ~/.bash_aliases
shopt -s expand_aliases

[[ $- != *i* ]] && return                   # If not running interactively, don't do anything

## General
set -o vi                                   # VIM mode for bash
bind -m vi-command 'Control-l: clear-screen'
bind -m vi-insert 'Control-l: clear-screen'
PATH=~/.local/bin:$PATH
export MANPAGER="/bin/sh -c \"col -b | vim --not-a-term -c 'set ft=man ts=8 nomod nolist noma' -\""
shopt -s checkwinsize                       # dynamic columns update after every cmd

## History
export HISTCONTROL=ignoreboth:erasedups     # No duplicate entries and started with spaces. See bash(1) for more options
shopt -s histappend cmdhist                 # saving multiline + append
export HISTSIZE=1000                        # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTFILESIZE=2000


## UI/UX
                                    # clors for .inputrc (set colored-stats On)
export LS_COLORS=$LS_COLORS:'tw=01;04;34:ow=01;04;34:'
                                    # set variable identifying the chroot you work in (used in the prompt below)
[ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ] && debian_chroot=$(cat /etc/debian_chroot)
                                    # Set a fancy prompt (non-color, unless we know we "want" color)
[[ $TERM == "xterm-color" ]] || [[ $TERM == *-256color ]] && color_prompt=yes
[ ! -x /usr/bin/tput ] || ! tput setaf 1 >&/dev/null && color_prompt=

function setPromt {
    if [ "$color_prompt" != yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
        return
    fi
    case "$TERM" in
    xterm*|rxvt*)
        ;;
    *)
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
        return
        ;;
    esac
    PROMPT_COMMAND=updatePromt
    PS2="|"
}
function updatePromt {
    local prev_exit="$?"
    # color_helper_>>color<< (Note: \[\]= escaping)
    local chR="\[\e[1;91m\]"      #red
    local chW="\[\033[00m\]"      #white
    local chG="\[\033[01;32m\]"   #green
    local chB="\[\033[0;34m\]"    #blue
    local chP="\[\033[0;35m\]"    #purple
    local chY="\[\033[0;33m\]"    #yellow
    PS1=""
    if [ $prev_exit == 0 ]; then
        PS1+="$chG✓ $chW"
    else
        PS1+="$chR✗ $chW"
    fi
    PS1+="${debian_chroot:+($debian_chroot)}"
    PS1+=" At ${chG}\A${chW}"
    PS1+=" by ${chP}\u${chW}"
    if sudo -n true 2>/dev/null; then
        PS1+="${chR} (sudo)${chW}"
    fi
    PS1+=" in "
    if \git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch="$(\git symbolic-ref -q HEAD)"
        PS1+="[${branch#refs/heads/}"
        local status="$(git for-each-ref --format='%(upstream:trackshort)' refs/heads | awk '!seen[$1]++ {printf $1}')"
        status+="$(git status --porcelain | awk '!seen[$1]++ {printf $1}')"
        if [ "$statua"s ]; then
            PS1+="|$chY$status$chW"
        fi
        PS1+="] "
    fi
    PS1+="${chB}\w${chW}"
    PS1+="\n:"
}
setPromt
unset color_prompt
unset -f setPromt

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
