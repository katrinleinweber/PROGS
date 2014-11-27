BEGIN{
	OFS="\t"
	depth=0
	print "Cruise	Station	Type	Date	Lon	Lat	Depth	Pressure	QF	Temperature	QF	Salinity	QF	Oxygen	QF"}
# extract lat and long from s87 header line
FNR==1{	Data=0;
	stn=$2;
	lat=$4;
	long=$5;
	date=$6; split(date,d,"/"); baddate=d[2] "/" d[3] "/" d[1];
	time=$8;
	id=$9;
	type=substr($1,1,1);
	}
/^&/{	match($0,/ZZ=[0-9]+/);
	depth=substr($0,RSTART+3,RLENGTH-3);
	}
Data{	print id,stn,type,baddate,long,lat,depth,$column["PR"],1,$column["TE"],1,$column["SA"],1,$column["OX"],1;
	}
/^@/{	Data=1;
	sub("^@","");
	cols=split($0,param);
	for (i=1;i<=cols;i++){column[param[i]]=i};
	}

