#! /bin/bash

OUTPUTFILE=$(mktemp)

gmtwrap pscoast -R-34/56/-40/41 -JM6i -W1/0 -Dc -P -B5 >> $OUTPUTFILE

gv $OUTPUTFILE

rm $OUTPUTFILE

