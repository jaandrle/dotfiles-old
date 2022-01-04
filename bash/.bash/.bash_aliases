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
history_clean(){ awk '!seen[$0]++ {print $0}' $HOME/.bash_history; }
history_most_used(){ LC_ALL=C cat ~/.bash_history | cut -d ';' -f 2- | _awk 1 | sort | uniq -c | sort -r -n | head -n ${1-10}; }
LAST_PWD_PATH="$BASH_DOTFILES/.bash_last_pwd"
[ -f "$LAST_PWD_PATH" ] && OLDPWD=`cat $LAST_PWD_PATH`
cd(){ builtin cd "$@" && echo `pwd` > "$LAST_PWD_PATH"; }
alias rm='rm -vi'
alias cp='cp -vi'
alias mv='mv -vi'
_?(){ alias | grep "alias _"; echo "_cd.."; echo "_gkeep"; ls ~/bin | grep -P "^_"; }
alias _ls='ls -pQF'
alias _ls.='_ls -A'
alias _cd.='clear;_ls'
_cd..(){ cd $(eval printf '../'%.0s {1..$1}); }
alias _find.='find . -maxdepth 1'

alias _psmem_all='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem'
alias _psmem='_psmem_all | head -n 10'
alias _pscpu_all='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu'
alias _pscpu='_pscpu_all | head -n 10'

alias _='clear'

alias _dotfiles='cd ~/Vzdálené/GitHub/dotfiles && git status'
