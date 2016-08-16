#! /bin/bash

if hash gmt 2> /dev/null ; then
	echo Running version 5 of GMT
	GMTWRAP=gmt
elif hash GMT 2> /dev/null ; then
	echo Running version 4 of GMT
	GMTWRAP=""
else
	echo An executable version of GMT is apparently not found.
	exit 1
fi

OUTPUTFILE=$(mktemp)

$GMTWRAP pscoast -R-34/56/-40/41 -JM6i -W -P -B5 >> $OUTPUTFILE

gv $OUTPUTFILE

rm $OUTPUTFILE

