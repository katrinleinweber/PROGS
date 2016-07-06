#!/bin/sh

# FILE=${1?}

# silly person who wrote pdftotext did a good job, 
# but forces us to use '-' to put output to stdout, instead of
# making writing to stdout the default, so it is not
# interchangeable with ps2ascii
# Further, if there is some copyright labelling in the file
# pdftotext refuses to present the text output. Cute but
# pointless. ps2ascii decodes the file without problem or
# comment. So what have you achieved, Mr pdftotext writer?
# Contempt. Disdain. Enmity. Cool huh?
#
# makeindex filename conflicts with unix utility for indexing
# troff latex other files. move my makeindex to makerefsindex

[ $# -eq "0" ] && { echo "$0: Missing file name"; exit 1; }

force=false

# test which reader to use
READPDF=`which pdftotext` ; OUTIND="-";
[ "$READPDF" ] || { READPDF=`which ps2ascii`; OUTIND=""; }
[ "$READPDF" ] || { echo No pdf reader found; exit 10 ; }

if $force; then
	READPDF=ps2ascii 
	OUTIND=""
fi

for FILE in $@ ; do  
  if [ ! -e  "$FILE" ] ; then
    echo "$FILE" not found
  elif [ -d "$FILE" ] ; then 
    echo $FILE is directory
  else
	# DEST="../Reprints/inrefs/new/pdf"
	DEST="inrefs"

	# LINK=$(find $FILE -printf "%l")
	# echo $LINK



	acroread "$FILE" &

	locate $(basename "$FILE")
	echo "$FILE"
	echo $( basename "$FILE" )
	ASCIIFILE=$(mktemp -t ascii.XXXXXXXXXX)
	$READPDF "$FILE" $OUTIND > $ASCIIFILE 

	(
	   echo Using $READPDF
	   locate `basename "$FILE"`
	   echo " " "$FILE" ; echo " " $(basename "$FILE") ;
		# grep -iE "\<doi\>" | sed -e 's/^.*[dD][oO][iI]:\? *//' -e 's/\.[ 	]*$//' 
	   awk 'BEGIN{dp=1}/References/{dp=0}dp{print}' $ASCIIFILE |
		grep -iE "\<doi\>" | sed -e 's/^.*[dD][oO][iI]:\? *//' -e 's/\([^ 	]\+\)[ 	]*.*$/\1/' -e 's/[.,]$//' 
	   cat $ASCIIFILE
	) |
		vim "+so view.com" -

# vim -R -c "so! view.com" -

	echo "Move ${FILE} to $DEST"
	# echo "Move  $LINK to $DEST/pdf"
	read -p "(Y/N/[F]orfiling/[T]rash/[Q]uit)? " A

	if [ "$A" = "y" -o "$A" = "Y" ]; then 
		if [ -d $DEST ]; then 
			mv -iv  "$FILE"  $DEST
			( cd $DEST
			  md5sum `basename "$FILE"` >> MD5SUM
			  ../makerefsindex -q -a $ASCIIFILE |
			  sed "s/^/$(basename "$FILE")	/" >> INDEX.idx
			)
		else
			echo $DEST is not a directory. Not moving "$FILE"
		fi
	elif [ "$A" = "f" -o "$A" = "F" ]; then
		if [ -d forfiling ]; then
			mv -iv "$FILE" forfiling
		else
			echo "Cannot shelve file. No forfiling directory."
		fi
	elif [ "$A" = "t" -o "$A" = "T" ]; then
		if [ -d trash ]; then
			mv -iv "$FILE" trash
		else
			echo "Cannot trash file. No trash directory."
		fi
	elif [ "$A" = "q" -o "$A" = "Q" ]; then
		exit
	fi
	rm $ASCIIFILE
  fi
done

du -sh inrefs


