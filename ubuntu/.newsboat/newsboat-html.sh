#!/usr/bin/bash

# $1–n = title, url, entry

. "$3"
titles=`curl -s $2 | xmllint --html --xpath $xpath$xpath_title - 2>/dev/null | sed 's/^\(.*\)/<title>\1<\/title>/'`
links=`curl -s $2 | xmllint --html --xpath $xpath$xpath_link - 2>/dev/null | sed 's/href="\(.*\)"/<link>\1<\/link>/'`
pubDates=`curl -s $2 | xmllint --html --xpath $xpath$xpath_updated - 2>/dev/null | sed 's/^\(.\.\)/0\1/' | sed 's/ \(.\.\)/ 0\1/' | sed 's/\(.*\)\. \(.*\)\. \(.*\)/<updated>\3-\2-\1T00:00:00+00:00<\/updated>/'`

SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char
titles=($titles)
pubDates=($pubDates)
links=($links)
IFS=$SAVEIFS   # Restore original IFS

echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<rss version=\"2.0\">
<channel>
	<title>$1</title>
	<link>$2</link>

"
for (( i=0; i<${#titles[@]}; i++ ))
do
	echo "	<item>"
	echo "		${titles[$i]}"
	echo "		${links[$i]}"
	echo "		${pubDates[$i]}"
	echo "	</item>"
done
echo -e "
</channel>
</rss>
"
