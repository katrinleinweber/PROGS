#!/bin/gawk -f
# 
# DDSTRANS: Translates raw DDS output (extracted from slave port)
#
# USAGE: gawk -f ddstrans.awk -f mathlib.awk [filename] [filename] ...
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
# 12. Course CMG                          Course
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
# 33. MTW Wire Out			
# 34. MTW Wire Speed			
# 35. MTW Wire Load			
# 36. ScW Wire Out			
# 37. ScW Wire Speed			
# 38. ScW Wire Load			
#
# Written: CM Duncombe Rae
# Modified from ddsparse.awk
# Date: 2000-05-16
# Modified: 2001-03-08: Changed to read raw data stream, updated the 
#	vIdentifier list 
# 
#

BEGIN{	first=1;
	FS="\t"
	OFS="\t";
	IDentifier[1]="Time (GMT)";
	IDentifier[2]="Date";
	IDentifier[3]="Latitude";
	IDentifier[4]="Longitude";
	IDentifier[5]="Grid";
	IDentifier[6]="Station";
	IDentifier[7]="Log (speed)";
	IDentifier[8]="Shaft Revs";
	IDentifier[9]="Sounding(metres)";
	IDentifier[10]="Heading";
	IDentifier[11]="Speed SMG";
	IDentifier[12]="Course CMG";
	IDentifier[13]="Sea Temperature (C)";
	IDentifier[14]="Salinity";
	IDentifier[15]="Fluorescence";
	IDentifier[16]="Light PAR";
	IDentifier[17]="Wind Speed Rel (k)";
	IDentifier[18]="Wind Dir Rel";
	IDentifier[19]="Air Pressure (mb)";
	IDentifier[20]="Air Temperature (C)";
	IDentifier[21]="Wind Speed true (k)";
	IDentifier[22]="Wind Dir true";
	IDentifier[23]="Rudder Angle";
	IDentifier[24]="PropPitch";
	IDentifier[25]="Humidity";
	IDentifier[26]="";
	IDentifier[27]="";
	IDentifier[28]="";
	IDentifier[29]="";
	IDentifier[30]="";
	IDentifier[31]="";
	IDentifier[32]="";
	IDentifier[33]="MTW Wire Out";
	IDentifier[34]="MTW Wire Speed";
	IDentifier[35]="MTW Wire Load";
	IDentifier[36]="ScW Wire Out";
	IDentifier[37]="ScW Wire Speed";
	IDentifier[38]="ScW Wire Load";
	}

# fix dos file in unix environment
{ gsub("","") }
# This is a counter, skip past it
NF==1{	
	print ""
	next;
	}
# process each parameter
{	DataVal=$2 }
# process some special parameters
($1+0)==1{	DataVal=substr($0,4);
	gsub(" ","0",DataVal);
	}
($1+0)==2{
	#  DataVal=substr($0,13,4) "-" substr($0,10,2) "-" substr($0,7,2);
	split($2,d,"/");
	DataVal=d[3] "-" d[2] "-" d[1];
	gsub(" ","0",DataVal);
	# print DataVal > "/dev/stderr"
	}
# $1==3{  DataVal=parsepos($3 " " $4) }
# $1==4{  DataVal=parsepos($3 " " $4) }
($1+0)==3{  DataVal=" " $2}
# ($1+0)==4{  DataVal=$3 " " $4}
# ($1+0)==6{  DataVal=$3 " " $4}
{ printf "%2d\t%19s\t%s\n", $1+0,IDentifier[$1+0],DataVal }

