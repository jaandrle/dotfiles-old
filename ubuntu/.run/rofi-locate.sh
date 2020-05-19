[ $# -eq 0 ] && ls -t -d /media/jaandrle/*/ ~ ~/* ~/*/* ~/*/*/* | sed -e 's:/home/jaandrle:~:' | sed -e "s:'::"
if [ $# -eq 1 ]
then
    cmd=$(echo "$1" | sed -e 's:~:/home/jaandrle:')
    xdg-open "$cmd" >/dev/null 2>&1 &
    exit 0
fi
