#!/usr/bin/gawk -f
BEGIN{ data=0
	grd=999
}
//{sub(//,"")}
/Sta\./{
#	stn=$2
        gsub(/[[:blank:]]*/,"");
        match($0,/:.*\|/);
        stn=substr($0,RSTART+1,RLENGTH-2);
	}
/Vessel/{ 
	sub(/Vessel/,""); 
	gsub(/[:|#]/,""); 
	gsub(/[ 	]+/," "); comment=$0;
#	print comment > "/dev/stderr"
	}
/Date/{
	dat=$6; 
	"date -d " dat " +%j" | getline yda 
	"date -d " dat " +%Y/%m/%d" | getline dat
	}
/Time/{ tim=$2 }
/Lat/{ lat=parsepos(substr($0,10,14)); }
/Long/{ lon=parsepos(substr($0,10,14)); }
/Depth/{
	# snd=$2
	gsub(/[[:alpha:]]*/,"");
        gsub(/[[:blank:]]*/,"");
        match($0,/:.*\|/);
        snd=substr($0,RSTART+1,RLENGTH-2);
	}
/-------/{
	getline; gsub(//,"")
	id="@" substr($1,1,2);
	for (i=2; i<=NF; i++){ id=id "\t" substr($i,1,2); }
	print "C9199",stn,grd,lat,lon,dat,yda,tim,comment
	print "& ZZ=" snd
	print id
	getline;sub(//,"")
	getline;sub(//,"")
	data=1
}
data{ gsub(",","\t"); gsub(" ","");  print } 	



#
# AWK Functions, Mathematical and Geophysical
#
# abs		absolute value
# pi		3.14159...
# distance	great circle distance (cos function)
# parsepos	parses position string
# date2day	converts date to day in year
#
function abs(x){ return x<0?-x:x }

function pi(){ return 4*(4*atan2(1,5)-atan2(1,239)) }

function distance(lat1,lon1,lat2,lon2,
		d,dlon,dlat,a,c){
	lat1=lat1/180*pi();
	lon1=lon1/180*pi();
	lat2=lat2/180*pi();
	lon2=lon2/180*pi();
	dlon = lon2 - lon1;
	dlat = lat2 - lat1;
	a = sin(dlat/2)^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2; 
	c = 2 * atan2( sqrt(a), sqrt(1-a) ); 
	if (c < 0) { c = pi() + c };
	d = 6367 * c;
	return d
	} 

function date2day(y,m,d,
		mn,M){
	D=0
	M="0,31,28,31,30,31,30,31,31,30,31,30"
	split(M,mn,",");
	if (y%100==0){y=y/100}
	if (y%4==0){mn[3]++}
	for (i=1;i<=m;i++){D+=mn[i]}
	D+=d;
	return D
	}
	

function parsepos(posstr,
		sign,angle,a,n,d){
#
#  parse the latitude or longitude string in posstr
#  recognizes any of the forms 
#	dd:mm:ss H
#	dd.dddd H
#	dd:mm.mmm H
#	dd:mm.mmmH
#	dd mm ss H 
#	dd:mm'ss"H 
#	ddHmm.mmm
#  etc
#  returns the position in the form
#  -dd.dddd
#  

	zone="undetermined"
	hemisphere="undetermined"
	d=1;sign=1;angle=0
# Determine the hemisphere if possible
	if (posstr~/[EeWw]/){
		zone="longitude";
		hemisphere=substr(posstr,match(s,"[EeWw]"))
		}
	if (posstr~/[NnSs]/){
		zone="latitude";
		hemisphere=substr(posstr,match(posstr,"[SsNn]"))
		}
# Determine whether the sign should be negative
	if (posstr~/[SsWw-]/){ sign=-1 }
# Split the string on any of the possible seperators
	n=split(posstr,a,"[ :'""eEsSwWnN-]")
# Add up the digits in the string. Make the assumption that each element
# degrees minutes seconds appears if a subordinate element is present, ie
# if degrees or minutes are zero and seconds are not, that is explicitly 
# stated rather than seconds being indicated by a quote or a blank in the 
# string
	for (i=1;i<=n;i++) { if (a[i]!~/^$/) { angle+=a[i]/d; d*=60 } }
	return sign*angle
	}

function badparsepos(s,
		sign,angle,a,n){
#
#  parse the latitude or longitude
#  recognizes any of the forms 
#	dd:mm:ss H
#	dd.dddd H
#	dd:mm.mmm H
#	dd mm ss H 
#  etc
#  returns the position in the form
#  -dd.dddd
#  leaving the hemisphere to be determined
#
	zone="undetermined"
	hemisphere="undetermined"
	d=1
	sign=1
	angle=0
	n=split(s,a,"[ :'""]")

	for (i=1;i<=n;i++) {
		if (a[i]!~/^$/){ 
			if (a[i]~/[EeWw]/){
				zone="longitude";
				hemisphere=substr(a[i],match(a[i],"[EeWw]"))
				}
			if (a[i]~/[NnSs]/){
				zone="latitude"
				hemisphere=substr(a[i],match(a[i],"[SsNn]"))
				}
			if (a[i]~/[SsWw]/){ sign=-1 }
			sub("[SsNnEeWw]","",a[i])
			angle+=a[i]/d
			d*=60
			}
		}
	return sign*angle
	}

