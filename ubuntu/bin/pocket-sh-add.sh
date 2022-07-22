[ ! -r ~/.config/pocketshaddrc ] && echo "\`~/.config/pocketshaddrc\` not found" && exit 1
. ~/.config/pocketshaddrc

curl -sS -X POST \
	-F "url=$1" \
	-F "title=$2" \
	-F "consumer_key=$CONSUMER_KEY" \
	-F "access_token=$ACCESS_TOKEN" \
	https://getpocket.com/v3/add \
	> /dev/null
