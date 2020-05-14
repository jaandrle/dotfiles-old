#!/bin/bash
cat /home/jaandrle/.synpadSettings | xargs synclient &
xinput set-prop --type=int --format=8  "Genius Optical Mouse" "Evdev Middle Button Emulation" 1 2>> ~/.Inicializations.log &
echo Inicializace nastaveni touchpadu: OK > ~/.Inicializations.log

unity-mail >> ~/.Inicializations.log 2>&1 &
echo Inicializace sluzby Unity Mail: OK >> ~/.Inicializations.log &

gsettings set org.gnome.nautilus.window-state geometry "811x460+98+41" 2>> ~/.Inicializations.log &
echo Inicializace nastaveni Nautila: OK >> ~/.Inicializations.log &

xmodmap -e 'keysym 0xff14 = Multi_key' 2>> ~/.Inicializations.log &
echo Inicializace nastaveni Multi_key: OK >> ~/.Inicializations.log &

#gnome-terminal -x bash -c 'cat ~/.Inicializations.log; exec bash'y &

xcalib -c & xcalib -b 6.5 -a & xcalib -gc 1.65 -a &

notify-send -i //usr/share/icons/Numix-Circle/48/apps/ubuntu-online-tour.svg "Nastavení úspěšně synchronizována
viz ~/.Inicializations.log"
