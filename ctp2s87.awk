#!/usr/bin/gawk -f
BEGIN{	GO=42.909
	OFS="\t"
	}

{	sub(//,"");}
	
FNR==1{ getline;sub(//,"");
	getline;sub(//,"");
	getline;sub(//,"");
	
	grd=$1;
	stn=$2;
	fil=$3;
	type=$4;
	sndg=$5;
	print type "9199 " stn " " grd " lat lon date day time cruise"
	print "& ZZ=" sndg+0
	print "# " strftime("%Y-%m-%d %T") ": conversion by ctp2s87.awk"
	print "@SA\tTE\tPR\tCO"
	getline;sub(//,"");
	getline;sub(//,"");
	getline;sub(//,"");
	getline;sub(//,"");
	getline;sub(//,"");
	
	}
{
	print sw_salt($3/GO,$2,$1), $2+0, $1+0, $3+0
	}

