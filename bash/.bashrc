#### BASH Config file
### Jan Andrle
## Info:
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for examples

## General
[[ $- != *i* ]] && return                   # If not running interactively, don't do anything
set -o vi                                   # VIM mode for bash
PATH=~/.local/bin:$PATH
export MANPAGER="/bin/sh -c \"col -b | vim --not-a-term -c 'set ft=man ts=8 nomod nolist noma' -\""
shopt -s checkwinsize                       # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
                                            # If set, the pattern "**" used in a pathname expansion context will, match all files and zero or more directories and subdirectories.
#shopt -s globstar
shopt -s expand_aliases

## History
export HISTCONTROL=ignoreboth:erasedups     # No duplicate entries and started with spaces. See bash(1) for more options
shopt -s histappend                         # append to the history file, don't overwrite it
shopt -s cmdhist
export HISTSIZE=1000                        # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTFILESIZE=2000


## UI/UX
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


## Programs/utils/aliases
                                    # Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
LAST_PWD_PATH="`pwd`/.bash_last_pwd"
[ -f "$LAST_PWD_PATH" ] && OLDPWD=`cat $LAST_PWD_PATH`
cd(){ builtin cd "$@" && echo `pwd` > "$LAST_PWD_PATH"; }
alias rm='rm -vi'
alias cp='cp -vi'
alias mv='mv -vi'
function _gkeep {
    #https://github.com/Nekmo/gkeep/tree/master
    gkeep --auth ~/Dokumenty/Google\ Keep/auth.txt search-notes > ~/Dokumenty/Google\ Keep/all.txt
    vim ~/Dokumenty/Google\ Keep/all.txt
}
_?(){ alias | grep "alias _"; echo "_cd.."; echo "_gkeep"; ls ~/bin | grep -P "^_"; }
alias _ls='ls -pQF'
alias _ls.='_ls -A'
alias _cd.='clear;_ls'
_cd..(){ cd $(eval printf '../'%.0s {1..$1}); }
alias _find.='find . -maxdepth 1'

alias _='clear'

alias _dotfiles='~/.run/syncDotfiles.sh'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
[ -f ~/.bash_aliases ] && . ~/.bash_aliases
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
