#!/bin/bash
#
# screenlock: lock screen on hibernate or suspend
# place in /etc/pm/sleep.d and run following
# chmod 755
# chown root:root

username=username # add username here; i.e.: username=foobar
userhome=/home/$username
export XAUTHORITY="$userhome/.Xauthority"
export DISPLAY=":0"
case "$1" in 
	hibernate|suspend)
	   #su $username -c "gnome-screensaver-command -l" # uncomment for activation
	   ;;
	thaw|resume)
           ;;
	*) exit $NA
	   ;; 
esac
