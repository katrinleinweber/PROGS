#!/bin/gawk
# 
# DDSPARSE: Parses DDS minute log files
#
# USAGE: gawk -f ddsparse.awk -f mathlib.awk [Var1,[Var2,...]] [filename] [filename] ...
#	where the optional Var1,Var2 list MUST be comma separated if
#	it is not to be interpreted as a filename. If the Var list is
#	not specified on the command line, the environment variable
#	DDSLIST is examined. If DDSLIST does not exist, the default
#	"Date,Time,Latitude,Longitude,SeaTemp,Salinity" is used.
#
# DDS output has the following identifier codes, related to this
# programs variables
#
# DDS Parameter list                      Variables
# -------------------
# 
# 1.  Time (GMT)                          Time
# 2.  Date                                Date
# 3.  Latitude                            Latitude
# 4.  Longitude                           Longitude
# 5.  Grid                                Gridno
# 6.  Station                             Station
#                                         Cruise
# 7.  Log (speed)                         Log
# 8.  Shaft Revs                          Shaft
# 9.  Sounding(metres)                    Sounding
# 10. Heading                             Heading
# 11. Speed SMG                           Speed
# 12. Course SMG                          Course
# 13. Sea Temperature (C)                 SeaTemp
# 14. Salinity                            Salinity
# 15. Fluorescence                        Fluorescence
# 16. Light PAR                           Light
# 17. Wind Speed Rel (k)                  WindSpeedRel
# 18. Wind Dir Rel                        WindDirRel
# 19. Air Pressure (mb)                   AirPress
# 20. Air Temperature (C)                 AirTemp
# 21. Wind Speed true (k)                 WindSpeedTrue
# 22. Wind Dir true                       WindDirTrue
# 23. Rudder Angle                        RudderAngle
# 24. PropPitch                           PropPitch
# 25. Humidity                            Humidity
#

# Written: CM Duncombe Rae
# Date: 1999-06-23
# Program Modifications
#	2000-05-16: Updated additional dds parameters 23-25
#	2001-04-25: output unix time stamp
#

BEGIN{	first=1; 
	OFS="\t";
# default output variable list
	OutPutList="Date,Time,Latitude,Longitude,SeaTemp,Salinity";
# examine the environment variable
	if (ENVIRON["DDSLIST"]~","){OutPutList=ENVIRON["DDSLIST"]};
# examine the command line
	if (ARGV[1]~","){OutPutList=ARGV[1]; delete ARGV[1]};
# parse the output variable list
	N=split(OutPutList,OutPutVars,",");
# make a format string. string must handle variable data and the separator
	for (n in OutPutVars){
		if (	OutPutVars[n]~"Date"||
			OutPutVars[n]~"Time"||
			OutPutVars[n]~"Latitude"||
			OutPutVars[n]~"Longitude"||
			OutPutVars[n]~"Station"||
			OutPutVars[n]~"Grid"){fmt[n]="%s%s"} else {fmt[n]="%g%s"}; 
#		print OutPutVars[n]
	}
	CalculateTime=OutPutList ~ /.*UnixTime.*/ 
		
}
# fix dos file in unix environment
{ gsub("","") }
FNR==1{print FILENAME > "/dev/stderr" }
NF==1{	if ( !first ){
# if it is a new record output the previous record
# if necessary calculate the unix timestamp
		if ( CalculateTime ){ 
			expr="date -d \"" DataVal["Date"] " " DataVal["Time"] "\" +%s"
			expr | getline DataVal["UnixTime"];
			close(expr);
			}
		for (i=1;i<=N-1;i++){
			printf fmt[i],DataVal[OutPutVars[i]],OFS 
			}; 
		printf fmt[i],DataVal[OutPutVars[N]],ORS;
		for (i in OutPutVars){DataVal[OutPutVars[i]]=""};
		};
	first=0;
	next;
	}
# process each parammter
$1==1{	DataVal["Time"]=substr($0,7,8);
	gsub(" ","0",DataVal["Time"]);
	}
$1==2{  DataVal["Date"]=substr($0,13,4) "-" substr($0,10,2) "-" substr($0,7,2);
	gsub(" ","0",DataVal["Date"]);
	}
$1==3{  DataVal["Latitude"]=parsepos($3 " " $4) }
$1==4{  DataVal["Longitude"]=parsepos($3 " " $4) }
$1==5{  DataVal["Gridno"]=$3 }
$1==6{  DataVal["Station"]=$3; DataVal["Cruise"]=$4;}
$1==7{  DataVal["Log"]=$3 }
$1==8{  DataVal["Shaft"]=$3 }
$1==9{  DataVal["Sounding"]=$3 }
$1==10{ DataVal["Heading"]=$3 }
$1==11{ DataVal["Speed"]=$3 }
$1==12{ DataVal["Course"]=$3 }
$1==13{ DataVal["SeaTemp"]=$3 }
$1==14{ DataVal["Salinity"]=$3 }
$1==15{ DataVal["Fluorescence"]=$3 }
$1==16{ DataVal["Light"]=$3 }
$1==17{ DataVal["WindSpeedRel"]=$3 }
$1==18{ DataVal["WindDirRel"]=$3 } 
$1==19{ DataVal["AirPress"]=$3 } 
$1==20{ DataVal["AirTemp"]=$3 }
$1==21{ DataVal["WindSpeedTrue"]=$3 }
$1==22{ DataVal["WindDirTrue"]=$3 }
$1==23{ DataVal["RudderAngle"]=$3 }
$1==24{ DataVal["PropPitch"]=$3 }
$1==25{ DataVal["Humidity"]=$3 }

