#!/bin/bash

### Should be setup in i3 config as follows:
## bindsym $mod+$N $SCRIPTPATH "$WORKSPACE" $PROGRAM1 $ARGS1;$PROGRAM2;...
# EXAMPLE: bindsym $mod+1 exec ~/.local/bin/i3workspaceprogram 1 firefox wwww.google.com www.news.google.com

## $mod should already be set in i3 config.
## $SCRIPTPATH is the location where script is saved.
## $N is the workspace number user wants to switch to.
## $PROGRAM is the program user wants to launch.
# $PROGRAM can take arguments as if it was starting from a regular terminal alone.

# Checks if workspace exists, if it doesn't start $PROGRAM on new workspace.
if ! i3-msg -t get_workspaces | grep \"num\":${1:1:1}; then
    i3-msg workspace $1
    # Using i3-msg to ensure new program starts on new workspace.
    IFS=';' read -ra ADDR <<< "${@:2}"
    echo "$ADDR"
    for i in "${ADDR[@]}"; do
        i3-msg exec "$i"
    done


# Only switch workspace if it already exists
else
    i3-msg workspace $1
fi
