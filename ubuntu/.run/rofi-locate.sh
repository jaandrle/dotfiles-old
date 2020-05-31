if [ $# != 1 ]
then
    ls -a -t -d /media/jaandrle/*/ ~ ~/* ~/*/* ~/*/*/* |\
        grep -v "$HOME/\(PlayOnLinux\|Šablony\|Dokumenty/NHL09\|snap\)" |\
        sed -e "s:$HOME:~:"
    exit
fi
case "$1" in !*)
    nohup catfish "${1#"!"}" >/dev/null 2>&1 &
    exit
esac
cmd=$(echo "$1" | sed -e 's:~:/home/jaandrle:')
xdg-open "$cmd" >/dev/null 2>&1 &
