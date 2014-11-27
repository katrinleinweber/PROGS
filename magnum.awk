BEGIN{
	}

{sub("","")}

/^Cruise/{match($0,/:.*$/);
	cruiseid=substr($0,RSTART+1,RLENGTH-1);
	}
/^Dip/{ vessel=$6; voyage=$9;
	if ($0~/Algoa/){platform="C91Al"};
	if ($0~/Africana/){platform="C91Af"};
	if ($0~/Agulhas/){platform="C91Ag"};
	}
/^Date/{ d=$3;
	split(d,dd,"/");
	dd[3]+=dd[3]<48?2000:1900;
	datestr=dd[3] "/" dd[2] "/" dd[1] ;
        "date -d " datestr " +%j" | getline day 
	}
/^Station/{ stnno=$3;
	grid=$7;
	}
/^Latitude/{ lati=parsepos(substr($0,11,13));
	long=parsepos(substr($0,36,13));
	}
/^Start/{ time=$3;
	}
/^Sounding/{ snd=$3
	}
# test for ^BOTTLE must come after this stanza
bottle && !data {
	# bottle data 
	}
/^BOTTLE/{ bottle=1
###	print platform,stnno,grid,lati,long,datestr,day,time,cruiseid,vessel,voyage;
	# clear the line of ---
	getline; sub("","");
	}
# test for ^READING must come after this stanza
data && bottle{
	# now reading continuous data
	#
	# parameters
	# READING TIME WIREOUT DEPTH TEMP FLUOR. CHLOR. U.LIGHT S.LIGHT L.RATIO
	# s87 identifiers
	# RN   TI   WO   DE   TE   FL   CA   LU   LS   LT
	#
	for (i=1; i<NF; i++){ printf "%g\t",$i }
	print $NF
	}
/^READING/{ data=1
	# clear line of ---
	getline; sub("","");
	print platform,stnno,grid,lati,long,datestr,day,time,cruiseid,vessel,voyage;
	# if bottle is not one then there is not bottle data?
	if (! bottle){print "# No bottle data"; bottle=1}
	print "@RN\tTI\tWO\tDE\tTE\tFL\tCA\tLU\tLS\tLT"
	}
END{
}
