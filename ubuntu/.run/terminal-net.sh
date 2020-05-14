#!/bin/bash
# by 

while true; do
  NET_ALL=($(ifstat -T -z -n 0.1 1 | tail -1 | awk -F "    " '{print $3 $4}' | sed "s/\./,/g"))
  NET_D=$(printf '%03.*f\n' 0 ${NET_ALL[0]})
  NET_U=$(printf '%03.*f\n' 0 ${NET_ALL[1]})
  echo -en "\rNET: d$NET_D u$NET_U\t\b\b"

  # Wait before checking again.
  sleep 1
done
