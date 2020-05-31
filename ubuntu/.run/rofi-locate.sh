[ $# -eq 0 ] && ls -a -t -d /media/jaandrle/*/ ~ ~/* ~/*/* ~/*/*/* |\
    grep -v "/home/jaandrle/\(PlayOnLinux\|Šablony\|Dokumenty/NHL09\|snap\)" |\
    sed -e 's:/home/jaandrle:~:'
if [ $# -eq 1 ]
then
    cmd=$(echo "$1" | sed -e 's:~:/home/jaandrle:')
    xdg-open "$cmd" >/dev/null 2>&1 &
    exit 0
fi
