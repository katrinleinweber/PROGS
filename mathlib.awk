#
# AWK Functions, Mathematical and Geophysical
#
# Author: C.M. Duncombe Rae
#
# abs(x)		absolute value
# signum(x)		sign of number [-1,0,1]
# round(x)		round to nearest integer
# pi()			pi by machin's formula
# nmile()		km per nautical mile
# distance(lat1,lon1,lat2,lon2,km)	great circle distance between two points
# leap(y)		leap year? [0,1]
# unixtime(y,m,d,H,M,S)	number of seconds since 24:00 31 December 1969
# date2day(y,m,d)	day of year
###  yearfrac(y,m,d,H,M,S)	fraction of the year
# posddm(decd)		position degrees and decimal minutes from decimal degree
# parsepos(posstr)	parse a string to decimal degrees
#

function abs(x){ return x<0?-x:x }

function signum(x){ return x<0?-1:x==0?0:1 }

function round(x){ return signum(x)*int(abs(x)+0.5) }

function pi(){ return 4*(4*atan2(1,5)-atan2(1,239)) }

function nmile(){ return 1.85325 }

function distance(lat1,lon1,lat2,lon2,km,
		R,d,dlon,dlat,a,c){
# default kilometres
	R=(km~/nm/)?3436:6367;
	lat1=lat1/180*pi();
	lon1=lon1/180*pi();
	lat2=lat2/180*pi();
	lon2=lon2/180*pi();
	dlon = lon2 - lon1;
	dlat = lat2 - lat1;
	a = sin(dlat/2)^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2; 
	c = 2 * atan2( sqrt(a), sqrt(1-a) ); 
	if (c < 0) { c = pi() + c };
	# d = 6367 * c;
	d = R * c;
	return d
	} 

function leap(y,
	d){
	y=y%100?y:y/100;
	d=y%4?0:1;
	return d;
}

function ut(str,
	a){
	split( str,a,"[-:;/, ]*");
	return unixtime(a[1],a[2],a[3],a[4],a[5],a[6]);
	}

function unixtime(y,m,d,H,M,S,
	i,yd,md,mday,ut,mstr)
#
## OY! Check that your input to this function is correct
## before you start changing things, thinking it is wrong! 
## Also check the time zone. "export TZ=GMT0" can fix many things.
## On the other hand sometimes there is a basic error in the algorithm.
## 2002-11-19 @sea Africana V171
# 
{
	yd=0; md=0;
	mstr="31,28,31,30,31,30,31,31,30,31,30,31"
	split(mstr,mday,",");
	for (i=1970;i<y;i++){ yd+=365; yd+=leap(i)};
	mday[2]+=leap(y)
	for (i=1;i<m;i++){md+=mday[i]}
	ut=( ( (yd+md+(d-1))*24 +H)*60 +M)*60 +S;
	# debugging
	# print "days=" yd "+" md "+" d-1
	# print ut "=" y "." m "." d "." H "." M "." S
	return ut;
	}

function date2day(y,m,d,
		i,D,mn,M){
	D=0
	M="0,31,28,31,30,31,30,31,31,30,31,30"
	split(M,mn,",");
	if (y%100==0){y=y/100}
	if (y%4==0){mn[3]++}
	for (i=1;i<=m;i++){D+=mn[i]}
	D+=d;
	return D
	}
	
function posddm(decd,hemis,
	sign,angle,a,n,d,sphere){
# kludge to return a position in degrees+decimalminutes from
# decimaldegrees
	sphere=" ";
	sign=signum(decd);
	a=abs(decd);
	d=int(a);
	if (hemis~/[nNsS]/){if (sign!=0){sphere=sign>0?"N":"S"};sign=1}
	if (hemis~/[eEwW]/){if (sign!=0){sphere=sign>0?"E":"W"};sign=1}
	return sprintf("%03d:%06.3f%1c",sign*d,(a-d)*60,sphere)
}

# function parsepos(posstr,posform,
function parsepos(posstr,
		i,sign,angle,a,n,d){
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
#  defined by posform, default -dd.dddd
#
#  
#  POSFORM needs to be completely defined.
#  use DMS for now

	zone="undetermined"
	hemisphere="undetermined"
	d=1;sign=1;angle=0
# Determine the hemisphere if possible
	if (posstr~/[EeWw]/){
		zone="longitude";
		hemisphere=substr(posstr,match(posstr,"[EeWw]"))
		}
	if (posstr~/[NnSs]/){
		zone="latitude";
		hemisphere=substr(posstr,match(posstr,"[SsNn]"))
		}
# Determine whether the sign should be negative
	if (posstr~/[SsWw-]/){ sign=-1 }
# Split the string on any of the possible seperators
# Note this also removes any minuses, so we don't have to worry about adding
# maybe a negative minutes to a positive degrees, for eg.
	n=split(posstr,a,"[ :'""eEsSwWnN-]")
# Add up the digits in the string. Make the assumption that each element
# degrees minutes seconds appears if a subordinate element is present, ie
# if degrees or minutes are zero and seconds are not, that is explicitly 
# stated rather than seconds being indicated by a quote or a blank in the 
# string
	
	for (i=1;i<=n;i++) { if (a[i]!~/^$/) { angle+=a[i]/d; d*=60 } }
	return sign*angle
	}

function human(num,
	unit){
# renders a number into human readable form.
# 2013-03-26 on Endeavor (SPURS2)
	if (num>1024){unit="k"; num/=1024}
	if (num>1024){unit="M"; num/=1024}
	if (num>1024){unit="G"; num/=1024}
	if (num>1024){unit="T"; num/=1024} 
	if (num>1024){unit="P"; num/=1024} 
	if (num>1024){unit="E"; num/=1024} 
	if (num>1024){unit="Z"; num/=1024} 
	if (num>1024){unit="Y"; num/=1024} 
	return sprintf("%.1f%c",num,unit)
	}

function c2f(c){
# converts celsius to fahrenheit
	return c*9/5+32
}

function f2c(f){
# converts fahrenheit to celsius
	return (f-32)*5/9
}

# vim: se nowrap tw=0 :

