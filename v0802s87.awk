BEGIN{data=0} 
{sub("","")}
/^Station/{stn=$2}
/^Grid/{grd=$2}
/^Latitude/{lat=parsepos($2 ":" $3)}
/^Longitude/{lon=parsepos($2 ":" $3)}
/^Date/{dat="19" substr($2,1,2) "-" substr($2,3,2) "-" substr($2,5,2);
	"date -d " dat " +%j" | getline day ;
	split($3,t,":");
	tim=sprintf("%02i:%02i",t[1],t[2]);
	}
/^Sound/{snd=$2}
data{print}
/^@/{ print "C9199 " stn,grd,lat,lon,dat,day,tim,"Agulhas Bank Boundary Processes Cruise";
	print "& ZZ=" snd
	print "@PR\tTE\tSA"
	data=1}
