BEGIN{data=0}
{gsub(//,"")}
/FileName/{stn=$4; stn=gensub(/^.*\\(.*).DAT/,"\\1",stn)}
/Bottle/{if (!data){gsub(/([^[:space:]]+)/,"\"&\""); print; data=1}}
/\(avg\)/{sub(/\(avg\)/,""); print "\"" stn "\"",gensub(/ ([JFMASOND][aepuco][nbrynlgptvc] [0-9][0-9] [12][90][0-9][0-9]) /," \"\\1\" ",1,$0)}
