#!/bin/zsh
# Converts a presentation from postscript to pdf.

psfile=${1:?Requires postscript file argument}
tempfile=`uniqfile`

pstops -w0 -h0 1:0R\(0in,8.27in\) $psfile > $tempfile
ps2pdf -g7930x5950 $tempfile $psfile:r.pdf

rm $tempfile
