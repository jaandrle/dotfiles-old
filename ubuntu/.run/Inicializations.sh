#!/bin/bash
cat /home/jaandrle/.synpadSettings | xargs synclient
xinput set-prop --type=int --format=8  "Genius Optical Mouse" "Evdev Middle Button Emulation" 1 2>> ~/.Inicializations.log &
echo Inicializace nastaveni touchpadu: OK > ~/.Inicializations.log

#unity-mail >> ~/.Inicializations.log 2>&1 &
#echo Inicializace sluzby Unity Mail: OK >> ~/.Inicializations.log &

#gsettings set org.gnome.nautilus.window-state geometry "811x460+98+41" 2>> ~/.Inicializations.log &
#echo Inicializace nastaveni Nautila: OK >> ~/.Inicializations.log &

#xmodmap -e 'keycode 78 = Multi_key' 2>> ~/.Inicializations.log
xfconf-query -c keyboard-layout -p /Default/XkbOptions/Compose -s ""
xfconf-query -c keyboard-layout -p /Default/XkbOptions/Compose -s "compose:sclk" 2>> ~/.Inicializations.log
xfconf-query -c keyboard-layout -p /Default/XkbOptions/Group -s ""
xfconf-query -c keyboard-layout -p /Default/XkbOptions/Group -s "grp:alt_caps_toggle" 2>> ~/.Inicializations.log
echo Inicializace nastaveni Multi_key: OK >> ~/.Inicializations.log

setxkbmap -option 2>> ~/.Inicializations.log
echo Inicializace opravy klavesy Alt: OK >> ~/.Inicializations.log

xcalib -c ; xcalib -b 6.5 -a ; xcalib -gc 1.6 -a 2>> ~/.Inicializations.log
echo Inicializace vylepseni jasu: OK >> ~/.Inicializations.log

#gnome-terminal -x bash -c 'cat ~/.Inicializations.log; exec bash'y &
notify-send -i distributor-logo-xubuntu "Nastavení úspěšně synchronizována viz ~/.Inicializations.log"
