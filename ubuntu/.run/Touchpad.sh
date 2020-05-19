#!/bin/bash
#xinput set-prop --type=int --format=8  "SynPS/2 Synaptics TouchPad" "Synaptics Locked Drags" 1
#xinput set-prop --type=int --format=8  "SynPS/2 Synaptics TouchPad" "Synaptics Circular Scrolling" 1
#xinput set-prop --type=int --format=16 "SynPS/2 Synaptics TouchPad" "Synaptics Circular Scrolling Trigger" 2

#gnome-terminal -x bash -c 'echo Inicializace nastaveni touchpadu; cat ~/.synpadSettings | xargs synclient; echo OK; exec bash' &
cat /home/jaandrle/.synpadSettings | xargs synclient &
xinput set-prop 11 "Synaptics Palm Detection" 1 &
xinput set-prop --type=int --format=8  "Genius Optical Mouse" "Evdev Middle Button Emulation" 1 &

notify-send -i distributor-logo-xubuntu "Nastavení poloh. zařízení úspěšně restartováno"
