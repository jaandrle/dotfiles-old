#!/bin/bash
output="gsettings get com.canonical.Unity.Lenses remote-content-search"
if [[ $(eval $output) = "'none'" ]]
then
  gsettings set com.canonical.Unity.Lenses remote-content-search all
else  
  gsettings set com.canonical.Unity.Lenses remote-content-search none
fi
