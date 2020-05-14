#!/bin/bash
mail-notification -u
sleep 30
mail-notification -s > ~/emails.xml
xml_grep --count //message ~/emails.xml > ~/emails.dat
echo -e "Zprávy v emailové schránce" > ~/Plocha/Aktivity/Emaily.txt
date >> ~/Plocha/Aktivity/Emaily.txt
echo -e "=========================\n" >> ~/Plocha/Aktivity/Emaily.txt
xmlstarlet sel -t -m //messages/message -v @subject -n -o "   (" -v @from -o ")" -n -n ~/emails.xml >> ~/Plocha/Aktivity/Emaily.txt
notify-send "Centrum Mail" "`tail --lines=1 ~/emails.dat`"
rm ~/emails.dat
rm ~/emails.xml
