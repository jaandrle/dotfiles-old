#!/bin/bash

# \Settings
	WD=~/Stažené #Work Directory
	TF=$WD/temp_radia.dat #Temp File
	HF=$WD/Libilo_se.html #Summary of all songs in temp file
	HF_title="Písně, které se mi líbily"
	RadioID=ch
	URL="http://www.songster.sk/json/$RadioID?full=1&html=only"
# /Settings

# \Prepare the temp file aka part of the html file
	echo >> $TF
	echo >> $TF
	curl $URL >> $TF
# /Prepare the temp file aka part of the html file

# \Create html file
	echo '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="cs" lang="cs"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>' > $HF
	echo $HF_title >> $HF
	echo '</title><style type="text/css">#main #s15_Cover {clear: left;padding-bottom: 15px;}#main div {padding-bottom: 35px;}</style></head><body><h1>' >> $HF
	echo $HF_title >> $HF
	echo '</h1><div id="main" style="position: absolute; width: 300px; ">' >> $HF
	cat $TF >> $HF
	echo '</div></body></html>' >> $HF
# /Create html file
