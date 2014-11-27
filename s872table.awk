#! /usr/bin/gawk  -f
# s872table -	Reads s87 format files and output STP data table
#
BEGIN{
	OFS="\t"
	}
{ sub(//,"") }
# extract lat and long from s87 header line
FNR==1{	Data=0;
	lat=$4;
	long=$5
	}
Data{	column["PR"]?pr="\t" $column["PR"]:pr="";
	column["TE"]?te="\t" $column["TE"]:te="";
	column["SA"]?sa="\t" $column["SA"]:sa="";
	column["OX"]?ox="\t" $column["OX"]:ox="";
	column["FL"]?fl="\t" $column["FL"]:fl="";
	column["TR"]?tr="\t" $column["TR"]:tr="";
	column["DE"]?de="\t" $column["DE"]:de="";
	print lat,long pr te sa ox fl tr de
	}
/^@/{	Data=1;
	sub("^@","");
	cols=split($0,param);
	for (i=1;i<=cols;i++){column[toupper(param[i])]=i};
	}

