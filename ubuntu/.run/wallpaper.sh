#!/bin/bash
# Script to randomly set Background from files in a directory
WALLS_PATH=/home/jaandrle/Tapety/Plocha/vybrane

# Get picture files
files=($WALLS_PATH/*)
# Random choise
PIC=`printf "%s\n" "${files[RANDOM % ${#files[@]}]}"`
# Set wallpaper
gsettings set org.gnome.desktop.background picture-uri "file://$PIC"

# ? For automatically change ?
#while [ 1 ]; do
#    for NEW_WALL in "$WALLS_PATH"/*; do
#        gsettings set org.gnome.desktop.background picture-uri "file://${NEW_WALL}"
#        sleep 1800
#    done
#done
