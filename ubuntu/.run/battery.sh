#!/bin/bash
output="gsettings get com.canonical.indicator.power show-percentage"
if [[ $(eval $output) = "false" ]]
then
  gsettings set com.canonical.indicator.power show-percentage true
  gsettings set com.canonical.indicator.power show-time true
else  
  gsettings set com.canonical.indicator.power show-percentage false
  gsettings set com.canonical.indicator.power show-time false
fi

