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

alias §ls='ls -pQFh --group-directories-first'
alias §less='less -R -S'

alias §cd.='clear;§ls'
§cd..(){ cd $(eval printf '../'%.0s {1..$1}); }
§cd(){
	[[ "$1" == '--help' ]] && echo -e "
	Usage: §cd NUMBER|PATH
	See: dirs -v
	" && return 0
	[[ -z "$1" ]] && dirs -v | sed 1d && return 0
	[[ $1 =~ ^[0-9]+$ ]] && cd "$(dirs -l +$1)" && dirs -v | sed 1d && return 0
	builtin pushd "$1" >/dev/null && pushd .
}
alias cd-vifm='cd `vifm --choose-dir -`'
mkcd(){ mkdir -p -- "$1" && cd -P -- "$1"; }

alias §find.='find . -maxdepth 1'

alias pdftk='java -jar $HOME/bin/pdftk-all.jar'
bw-session(){
	bw logout
	login=`kwallet-query kdewallet -f accounts -r Bitwarden 2> /dev/null`
	export BW_CLIENTSECRET=`echo "$login" | jq -r .secret`
	export BW_CLIENTID=`echo "$login" | jq -r .id`
	bw login --apikey --raw
	export BW_SESSION=`bw unlock --raw $(echo "$login" | jq -r .pass)` && echo "Bitwarden session ON" ||  echo "Bitwarden session FAILED"
	unset BW_CLIENTSECRET
	unset BW_CLIENTID
}

alias §psmem_all='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem'
alias §psmem='§psmem_all | head -n 10'
alias §pscpu_all='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu'
alias §pscpu='§pscpu_all | head -n 10'
alias §psnet_all='lsof -P -i -n'

§ping-test(){ # Pings ip address of noip.com and www.google.com.
  ping -c 1 -q 8.23.224.107 | grep --color=never -A 1 -i '\---'
  ping -c 1 -q www.google.com | grep --color=never -A 1 -i '\---'
}
§whoami(){
	[[ "$1" == '--help' ]] && echo '§whoami; §whoami --ip' && return 0
	local ip=$(curl -s ifconfig.me)
	[[ "$1" == '--ip' ]] && echo "$ip" && return 0
	local L="	%s\n"
	printf "\n"
	printf "$L" "USER: $(echo $USER)"
	printf "$L" "IP ADDR: $ip"
	printf "$L" "HOSTNAME: $(hostname -f)"
	printf "$L" "KERNEL: $(uname -rms)"
	printf "\n"
}
§cmdfu(){ curl "https://www.commandlinefu.com/commands/matching/$@/$(echo -n $@ | openssl base64)/plaintext"; }
aai(){
	[[ "$1" == '--help' ]] && ai ask --help && return 0;
	echo "ai ask \"$*, thanks for your help\""; ai ask "\"$*, thanks for your help\"";
}

alias npx-wca='npx -y web-component-analyzer'
alias npx-qnm='npx -y qnm'
alias npx-hint='npx -y hint'
alias npx-markdown='nohup npx markserv'
alias zfz=fzf-carroarmato0.fzf

§url-curl(){ curl --silent -I "$1" | grep -i location; }

alias bathelp='bat --plain --language=help'

# alias adb-device='adb devices | tail -n +2 | head -n 1 | §awk 1'
# make-completion-wrapper, see https://gdhnotes.blogspot.com/2014/02/alias-bash-completion.html
