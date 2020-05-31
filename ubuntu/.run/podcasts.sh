#!/bin/sh

case "$1" in
    news )
        (
mkdir -p ~/Stažené/Podcasts/Audio/
wget -O ~/Stažené/Podcasts/Audio/RozhlasPlusZpravy$2.mp3 http://static.rozhlas.cz/news/plus/$(date +"%Y/%m/%d")/"$2"0000.mp3
wget -N -P ~/Stažené/Podcasts/Audio/ http://media.blubrry.com/radio_prague_media/rebel.radio.cz/mp3/podcast/cz/ekonomika/ekonomicky-prehled-tydne--$((43+$(date +%V))).mp3
wget -N -P ~/Stažené/Podcasts/Audio/ http://wsdownload.bbc.co.uk/worldservice/css/32mp3/latest/bbcnewssummary.mp3
        )
        ;;
    cnews-web )
        (
netrik cnews.cz/tagy/cnews-fm
        )
        ;;
    cnews-download )
        (
mkdir -p ~/Stažené/Podcasts/Audio/
wget -P ~/Stažené/Podcasts/Audio/ http://www.cnews.cz/sites/default/files/pictures/podcast/cnewsfm-$2.mp3
        )
        ;;
    cnews )
        (
        if [ $2 ]; then
            $0 cnews-download $2
            exit
        fi
        $0 cnews-web
        )
        ;;
    stream )
        (
shift
youtube-dl -o "~/Stažené/Podcasts/Video/%(title)s-%(id)s.%(ext)s" -f mp4-360p $@
        )
        ;;
    play )
        (
vlc --quiet ~/Stažené/Podcasts/$2/ 2>/dev/null &
exit
        )
        ;;
    ls )
        (
echo Audio
ls --color=always -1 ~/Stažené/Podcasts/Audio/ 2>/dev/null
echo Video
ls --color=always -1 ~/Stažené/Podcasts/Video/ 2>/dev/null
exit
        )
        ;;
    move )
        (
cd ~/Stažené/Podcasts/Audio/
for FILENAME in * ; do mv $FILENAME /media/jaandrle/ANDRLE_JAN/VOICE/A00-$FILENAME; done
echo Audio presunuto
exit
        )
        ;;
    *)
        (
        echo
        echo " 'podcasts' je wrapper nad wget  a youtube-dl, který zjednodušuje
   stahování video/audio podcastů."
        echo
        echo "   Skript podporuje příkazy:"
        echo "     * news CELÁ_HODINA (využívá wget)"
        echo "     * cnews _/DÍL (využívá wget)"
        echo "      **  (případně přímo příkazy: cnews-web/cnews-download DÍL)"
        echo "     * stream ODKAZY (využívá youtube-dl)"
        echo "     * play Video/Audio (využívá VLC)"
        echo "     * ls"
        echo
        echo "   Díly jsou uchovávány ve složce ~/Stažené/Podcasts/Video resp. /Audio"
        echo
        )
        ;;
esac
