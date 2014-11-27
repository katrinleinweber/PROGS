#!/usr/bin/gawk -f
# s872fullt - Reads s87 files and outputs table including date/time
#
BEGIN{
	OFS="\t"
	}
# extract lat and long from s87 header line
FNR==1{	Data=0;
	lat=$4;
	long=$5
# quote date space time quote
	stime= "\"" $6 " " $8 "\""
# invoke a system call
	"date -d " stime " +%s" | getline ftime 
	}
Data{	print ftime,lat,long,$column["PR"],$column["TE"],$column["SA"],$column["OX"];
	}
/^@/{	Data=1;
	sub("^@","");
	cols=split($0,param);
	for (i=1;i<=cols;i++){column[toupper(param[i])]=i};
	}

