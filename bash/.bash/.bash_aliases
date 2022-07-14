                                    # Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
# enable color support of ls and also add handy aliases
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
alias §rm='rm -vi'
alias §cp='cp -vi'
alias §mv='mv -vi'
alias §df='df -Th'
§du(){
    [[ "$1" == '--help' ]] && echo "§du; §du '../*'" && return 0
    du -h -x -s -- ${1:-*} | sort -r -h;
}

alias §xclip-copy='xclip -selection clipboard'
alias §xclip-paste='xclip -o -selection clipboard'

LAST_PWD_PATH="$BASH_DOTFILES/.bash_last_pwd"
[ -f "$LAST_PWD_PATH" ] && OLDPWD=`cat $LAST_PWD_PATH`
cd(){ builtin cd "$@" && echo `pwd` > "$LAST_PWD_PATH"; }

history_clean(){ awk '!seen[$0]++ {print $0}' $HOME/.bash_history; }
history_edit(){ vim $HOME/.bash_history; }
history_cat(){ LC_ALL=C cat ~/.bash_history; }
history_most_used(){ LC_ALL=C cat ~/.bash_history | cut -d ';' -f 2- | §awk 1 | sort | uniq -c | sort -r -n | head -n ${1-10}; }

§(){
    [[ -z "$1" ]] && clear && return 0
    echo "$ [--help]= clear or [print this text]"
    alias | grep "alias §" --color=never
    declare -F | grep 'declare -f §' --color=never
    ls ~/bin | grep -P "^§" | sed 's/^§/~\/bin\/ §/'
}

if [[ `lsb_release -a 2>/dev/null | grep 'Distributor ID' | cut --delimiter='	' -f 2-` == "Neon" ]]; then
    alias §apt-uu='echo ":: pkcon refresh ::" && sudo pkcon refresh && echo ":: pkcon update ::" && sudo pkcon update'
else
    alias §apt-uu='echo ":: apt update ::" && sudo apt update && echo ":: apt upgrade ::" && sudo apt upgrade'
fi
alias §ls='ls -pQFh --group-directories-first'
alias §ls.='§ls -A'
alias §less='less -R -S'
§lsl(){ §ls. -l $* --color=always | §less; }

alias §cd.='clear;§ls'
§cd..(){ cd $(eval printf '../'%.0s {1..$1}); }

alias §find.='find . -maxdepth 1'

alias §psmem_all='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem'
alias §psmem='§psmem_all | head -n 10'
alias §pscpu_all='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu'
alias §pscpu='§pscpu_all | head -n 10'

alias §dotfiles='cd ~/Vzdálené/GitHub/dotfiles && git status'

§ping-test(){ # Pings ip address of noip.com and www.google.com.
  ping -c 1 -q 8.23.224.107 | grep --color=never -A 1 -i '\---'
  ping -c 1 -q www.google.com | grep --color=never -A 1 -i '\---'
}
§whoami(){
    [[ "$1" == '--help' ]] && echo '§whoami; §whoami --ip' && return 0
    local ip=$(curl -s ifconfig.me)
    [[ "$1" == '--ip' ]] && echo "$ip" && return 0
    local L="   %s\n"
    printf "\n"
    printf "$L" "USER: $(echo $USER)"
    printf "$L" "IP ADDR: $ip"
    printf "$L" "HOSTNAME: $(hostname -f)"
    printf "$L" "KERNEL: $(uname -rms)"
    printf "\n"
}
pushd(){ builtin pushd "$@" >/dev/null && dirs -v; }
popd() { builtin popd "$@" >/dev/null  && dirs -v; }

alias npx-wca='npx -y web-component-analyzer'
alias npx-qnm='npx -y qnm'
alias npx-hint='npx -y hint'
alias zfz=fzf-carroarmato0.fzf
