#! /bin/bash
# Is GMT installed on the system? Is it running correctly? 
# Draw a quick picture of Africa and test whether GMT is installed.

OUTPUTFILE=$(mktemp)

gmtwrap pscoast -R-34/56/-40/41 -JM6i -W1/0 -Dc -P -B5 >> $OUTPUTFILE

gv $OUTPUTFILE

rm $OUTPUTFILE

