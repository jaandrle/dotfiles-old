#!/bin/bash
# Script to toggle caffeine program v 2.7.2

#if (ps -A | grep caffeine) then
#  pkill caffeine
#  sleep 5
#  if (ps -A | grep caffeine) then
#    pkill -9 caffeine
#  fi
#  notify-send "Caffeine ukončeno!" -i "caffeine-cup-empty.svg" -t 10
#else
#  nohup caffeine &
#  notify-send "Caffeine spuštěno!" -i "caffeine-cup-full.svg" -t 10
#fi

if (gsettings get org.gnome.desktop.session idle-delay | grep 180) then
	gsettings set org.gnome.desktop.session idle-delay 0
	notify-send "Obrazovka nebude vypnuta při nečinosti!" -i "caffeine-cup-empty.svg" -t 10
else
	gsettings set org.gnome.desktop.session idle-delay 180
	notify-send "Obrazovka bude vypnuta při nečinosti delší než 3 minuty!" -i "caffeine-cup-empty.svg" -t 10
fi
