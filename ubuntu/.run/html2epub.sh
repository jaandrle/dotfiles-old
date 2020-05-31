#!/bin/bash

# Converts an HTML file to EPUB format
#
# Angel Ortega <angel@triptico.com>
# Shakna Israel <s4b3r6@gmail.com>
#
# Public domain
function load_data
{
saveIFS="$IFS"
IFS=$'\n'
array=($(<book.dat))
IFS="$saveIFS"
eval 'EPUB=${array[0]}'
shift
eval 'TITLE=${array[0]}'
eval 'AUTHOR=${array[1]}'
eval 'LANG=${array[2]}'
eval 'HTML=${array[3]}'
eval 'COVER=${array[4]}'
eval 'SUBJECT=${array[5]}'
eval 'CREATOR=${array[6]}'
eval 'PUBLISHER=${array[7]}'
UUID="c5be00f9-932e-4903-8cd9-b4b5939411a6"
}
function help_func
{

    echo "Usage: in folder must be book.dat."
    echo "Every line make set of variables"
    echo "(if not empty = unset)."
    echo
    echo "Lines and variables are in these order:"
    echo "1.TITLE        Book title"
    echo "2.AUTHOR       Book author"
    echo "3.LANG         Language (en, es, fr...)"
    echo "4.HTML         HTML files (*.html)Book creator"
    echo "5.COVER        Cover image (PNG format)"
    echo "6.SUBJECT      Book sunject"
    echo "7.CREATOR      Book creator"
    echo "7.PUBLISHER    Book publisher"
}

load_data

if [ -z "$EPUB" ] ; then
    help_func
    echo
    echo "$0: No book.dat; aborting"
    exit 1
fi

if [ -z "$HTML" ] ; then
    help_func
    echo
    echo "$0: No HTML files; aborting"
    exit 2
fi

rm -f ${EPUB}

##################################################

# if the uuidgen utility is installed, generate an UUID
if which uuidgen 2>&1 >/dev/null ; then
    UUID="$(uuidgen)"
fi

O="titlepage.xhtml"
> ${O}
echo "<?xml version='1.0' encoding='utf-8'?>" >> ${O}
echo '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">' >> ${O}
echo "<head><title>${TITLE} - ${AUTHOR}</title></head><body>" >> ${O}

if [ ! -z "${COVER}" ] ; then
    echo "<img src='${COVER}'/>" >> ${O}
else
    echo "<h1>$TITLE</h1><h2>$AUTHOR</h2>" >> ${O}
fi

echo "</body></html>" >> ${O}

mkdir -p META-INF
O="META-INF/container.xml"

> ${O}
echo '<?xml version="1.0"?>' >> ${O}
echo '<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">' >> ${O}
echo '   <rootfiles>' >> ${O}
echo '      <rootfile full-path="content.opf" media-type="application/oebps-package+xml"/>' >> ${O}
echo '   </rootfiles>' >> ${O}
echo '</container>' >> ${O}

echo -n "application/epub+zip" > mimetype

O=content.opf
>${O}

echo '<?xml version="1.0" encoding="utf-8"?>' >> ${O}
echo '<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="uuid_id">' >> ${O}
echo '  <metadata xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:calibre="http://calibre.kovidgoyal.net/2009/metadata" xmlns:dc="http://purl.org/dc/elements/1.1/">' >> ${O}
echo "    <dc:language>${LANG}</dc:language>" >> ${O}
echo "    <dc:title>${TITLE}</dc:title>" >> ${O}
echo "    <dc:creator opf:role=\"aut\">${AUTHOR}</dc:creator>" >> ${O}
echo "    <dc:identifier id='uuid_id' opf:scheme='uuid'>${UUID}</dc:identifier>" >> ${O}
echo "    <dc:date>$(date +%Y-%m-%d)</dc:date>" >> ${O}
echo "    <dc:subject>${SUBJECT}</dc:subject>" >> ${O}
echo "    <dc:creator>${CREATOR}</dc:creator>" >> ${O}
echo "    <dc:publisher>${PUBLISHER}</dc:publisher>" >> ${O}
echo '    <dc:rights>Creative Commons BY-SA 3.0 License.</dc:rights>' >> ${O}
echo '  </metadata>' >> ${O}
echo '  <manifest>' >> ${O}

if [ ! -z "$COVER" ] ; then
    echo "    <item href='${COVER}' id='cover' media-type='image/png'/>" >> ${O}
fi

echo "    <item href='titlepage.xhtml' id='titlepage.xhtml' media-type='application/xhtml+xml'/>" >> ${O}

for f in ${HTML} ; do
    echo "    <item href='${f}' id='${f}' media-type='application/xhtml+xml'/>" >> ${O}
done

echo '    <item href="toc.ncx" media-type="application/x-dtbncx+xml" id="ncx"/>' >> ${O}
echo '  </manifest>' >> ${O}
echo '  <spine toc="ncx">' >> ${O}

echo "    <itemref idref='titlepage.xhtml'/>" >> ${O}

for f in ${HTML} ; do
    echo "    <itemref idref='${f}'/>" >> ${O}
done

echo '  </spine>' >> ${O}
echo '  <guide>' >> ${O}
echo '    <reference href="titlepage.xhtml" type="cover" title="Cover"/>' >> ${O}
echo '  </guide>' >> ${O}
echo '</package>' >> ${O}

O=toc.ncx
> ${O}

echo '<?xml version="1.0" encoding="utf-8"?>' >> ${O}
echo "<ncx xmlns='http://www.daisy.org/z3986/2005/ncx/' version='2005-1' xml:lang='${LANG}'>" >> ${O}
echo '  <head>' >> ${O}
echo "    <meta content='${UUID}' name='dtb:uid'/>" >> ${O}
echo '    <meta content="2" name="dtb:depth"/>' >> ${O}
echo '    <meta content="aov-html2epub" name="dtb:generator"/>' >> ${O}
echo '    <meta content="0" name="dtb:totalPageCount"/>' >> ${O}
echo '    <meta content="0" name="dtb:maxPageNumber"/>' >> ${O}
echo '  </head>' >> ${O}
echo '  <docTitle>' >> ${O}
echo "    <text>$TITLE - $AUTHOR</text>" >> ${O}
echo '  </docTitle>' >> ${O}
echo '  <navMap>' >> ${O}

ID=0

for f in ${HTML} ; do
    echo "    <navPoint id='${f}' playOrder='${ID}'>" >> ${O}
    echo "      <navLabel><text>${f}</text></navLabel>" >> ${O}
    echo "      <content src='${f}'/>" >> ${O}
    echo "    </navPoint>" >> ${O}

    ID=$(($ID + 1))
done

echo '  </navMap>' >> ${O}
echo '</ncx>' >> ${O}

FILES="META-INF titlepage.xhtml content.opf toc.ncx"

zip "${EPUB}" -X -Z store mimetype
zip "${EPUB}" -X -r ${FILES} ${COVER} ${HTML}

rm -rf mimetype ${FILES}

exit 0
