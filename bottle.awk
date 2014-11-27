BEGIN{ first=1; OFS="\t"; }
{gsub(//,"")}
/FileName/{cast=gensub(/^.*\\(.*)\.DAT/,"\\1","g",$4)}
/Bottle/{if (first) {print "File","Cast",$0} else {print "-"}; first=0}
/\(avg\) *$/{
	sub(/\(avg\) *$/,""); 
	sub(/[ADFJMNOS][aceopu][bcglnprtvy] [0-9][0-9] [129][0129][0-9][0-9]/,"\"&\"");
	print FILENAME,cast,$0
	}
