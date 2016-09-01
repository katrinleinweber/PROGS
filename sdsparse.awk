#!/usr/bin/gawk -f
#
# SDSPARSE:  parses the contents of SDS log file
#
# USAGE: gawk -f sdsparse.awk -f mathlib.awk [Var1,[Var2,...]] [filename] ...
#       where the optional Var1,Var2 list MUST be comma separated if
#       it is not to be interpreted as a filename. If the Var list is
#       not specified on the command line, the environment variable
#       DDSLIST is examined. If DDSLIST does not exist, the default
#       "Date,Time,Latitude,Longitude,SeaTemp,Salinity" is used. If
#	"UnixTime" is in the variable list, the Unix timestamp 
#	(seconds since 1 January 1970) is calculated.
#
# 	Date returns date in the format YYYY-mm-dd
#	BadDate returns date in (mm/dd/YYYY) format
#	RawDate returns date in NDS format (dd/mm/YYYY)

# A sample:			; with comments and		: Variable
#
# 00:00:00  25/05/2001		; time and date			: Time Date
# 02 VNUM 156			; voyage number			: Cruise
# 05 LAT  32 15.74S		; GPS latitude			: Latitude
# 06 LONG 016 54.12E		; GPS longitude			: Longitude
# 07 STAT DiffFix
# 08 PSTA Valid
# 09 WSTA 1
# 10 BSTA 
# 11 MINS 1734
# 12 STN  			; ships station number		: Station
# 13 GRID 			; survey grid number		: Gridno
# 14 PGRD mmm
# 15 SCOD 
# 16 SCOM 
# 17 DEUN M
# 18 FLUN 
# 19 ATUN Deg.C
# 20 APUN hPa
# 21 HUUN %RH
# 22 SPR1 
# 23 SPR2 
# 24 SPD  			; speed				: Log
# 25 HDG  346			; heading			: Heading
# 26 SOG  11.4			; speed over ground		: Speed
# 27 COG  346			; course over ground		: Course
# 28 SPR3 
# 29 SPR4 
# 30 DPTH 298.2			; sounding			: Sounding
# 31 AIRT 15.6			; air temperature		: AirTemp
# 32 AIRP 1010			; air pressure			: AirPress
# 33 HUM  89.2			; relative humidity		: Humidity
# 34 SEAT 24.8			; sea temperature		: SeaTemp
# 35 SAL  34.09			; sea salinity			: Salinity
# 36 FLUO 			; fluorescence?			: Fluor
# 37 LGHT 			; light?			: Light
# 38 WSTK 33.6			; wind speed true knots?	: WndSpdTK
# 39 WSTM 17.3			; wind speed true m/s?		: WndSpdTM
# 40 WDT  349			; wind direction true?		: WindDirT
# 41 WSRK 			; wind speed relative knots?	: WndSpdRK
# 42 WSRM 			; wind speed relative m/s?	: WndSpdRM
# 43 WDR  002			; wind direction relative?	: WindDirR
# 44 HYWO 0000			; hydro wire out		: HydWO
# 45 HYWS 0.0			; hydro wire speed		: HydWSpd
# 46 HYWL 00.00			; hydro wire load		: HydWLd
# 47 BTWO 0000			; Bio wire out			: BioWO
# 48 BTWS 0.0			; hydro wire out		: BioWSpd
# 49 BTWL 00.00			; hydro wire out		: BioWLd
# 50 LTWO 			; hydro wire out		: LTWO
# 51 LTWS 			; hydro wire out		: LTWSpd
# 52 LTWL 			; hydro wire out		: LTWLd
# 53 SHWO 			; wire out			: SHWO
# 54 SHWS 			; wire speed			: SHWSpd
# 55 SHWL 			; wire load			: SHWLd
# 56 MPWO 0001			; Main trawl port wire out	: MPWO
# 57 MPWS 0.0			; Main trawl port wire speed	: MPWSpd
# 58 MPWL 0001 			; Main trawl port wire load	: MPWLd
# 59 MSWO 0001			; Main trawl stbd wire out	: MSWO
# 60 MSWS 000			; Main trawl stbd wire speed	: MSWSpd
# 61 MSWL 0001 			; Main trawl stbd wire load	: MSWLd
# 62 REVS 			; Shaft revs
# 

# Written: CM Duncombe Rae, somewhat modified from ddsparse.awk then
# ndsparse.awk
# Date: 2001-05-25 on Africana Trials V156
# Mods: 2002-09-25 on Africana Trials V169
# Mods: 2002-11-11 on Africana Pelagic Spawner V171
# Mods: 2016-08-31 
#
#

# BEGIN{
# 	first=1; 
# 	# OFS="\t";
# 	OFS="  ";
# 	if (HEADER_SKIP==""){HEADER_SKIP=20;}
# 	if (POS_FORMAT==""){POS_FORMAT="Degree";}
# # default output variable list
# 	OutPutList="Date,Time,Latitude,Longitude,SeaTemp,Salinity";
# # examine the environment variable
# 	if (ENVIRON["DDSLIST"]~","){OutPutList=ENVIRON["DDSLIST"]};
# # examine the command line
# 	if (ARGV[1]~","){
# 		OutPutList=ARGV[1];
# 		delete ARGV[1];
# 		} else {
# 		if (ARGV[1]~/help/){
# 		# Print entire recognised list
# 
# 			print "Some variable names recognised are: "
# 			print " Gridno\n Station\n Cruise\n Log\n Sounding\n Heading\n Speed\n Course\n SeaTemp\n Temperature\n Salinity\n Fluor\n Light\n AirPress \n AirTemp\n Humidity\n WndSpdTK\n WndSpdTM\n WindDirT\n WndSpdRK\n WndSpdRM\n WindDirR\n HydWO\n HydWSpd\n HydWLd\n BioWO\n BioWSpd\n BioWLd\n LTWO\n LTWSpd\n LTWLd\n SHWO\n SHWSpd\n SHWLd\n MPWO\n MPWSpd\n MPWLd\n MSWO\n MSWSpd\n MSWLd\n "
# 			exit;
# 
# 			}
# 		}
# # parse the output variable list
# 	N=split(OutPutList,OutPutVars,",");
# # make a format string
# 	for (n in OutPutVars){ 
# 		fmt[n]="%8g%s"; hfmt[n]="%8s%s";
# 	if (	OutPutVars[n]~"Time"||
# 		OutPutVars[n]~"Latitude"||
# 		OutPutVars[n]~"Longitude"||
# 		OutPutVars[n]~"Station"||
# 		OutPutVars[n]~"Grid"){
# 		fmt[n]="%8s%s" }
# 	if (	OutPutVars[n]~"Date"){
# 		fmt[n]="%10s%s"; hfmt[n]="%10s%s"}
# 	if (	PRINT_HEADER && (OutPutVars[n]~"Latitude"|| OutPutVars[n]~"Longitude")){
# 		fmt[n]="%12s%s"; hfmt[n]="%12s%s"}
# 		}
# 	}
# # fix dos file in unix environment
# { gsub("","") }
# FNR==1{print FILENAME > "/dev/stderr" }
# /^$/{  if ( !first ){
# # if it is a new record output the previous record
# 	if (PRINT_HEADER){ 
# 			if (NRECS++%HEADER_SKIP==0){
#   				for (i=1;i<=N;i++){printf hfmt[i], OutPutVars[i],OFS}; 
# 				printf "\n"
# 			}
# 	}
# 	for (i=1;i<=N-1;i++){ printf fmt[i],DataVal[OutPutVars[i]],OFS } ; 
# 	printf fmt[i],DataVal[OutPutVars[N]],ORS;
# 	for (i in OutPutVars){DataVal[OutPutVars[i]]=""};
# 	};
# 	first=0;
# 	fflush();
# 	next;
# }
# # process each parameter
# /^[[:digit:]][[:digit:]]:[[:digit:]][[:digit:]]:[[:digit:]][[:digit:]]/{
# 	DataVal["Time"]=substr($0,1,8);
#         gsub(" ","0",DataVal["Time"]);
# 	year=substr($0,17,4);
# 	month=substr($0,14,2);
# 	day=substr($0,11,2);
# 	DataVal["RawDate"]=substr($0,11,10);
# 	DataVal["Date"]=year "-" month "-" day;
# 	DataVal["BadDate"]=month "/" day "/" year;
# 
#         gsub(" ","0",DataVal["Date"]);
# #	Command="date -d \"" DataVal["Date"] " " DataVal["Time"] "\" +%s" ;
# #	Command | getline DataVal["UnixTime"];
# #	close(Command);
# 	split(DataVal["Date"],Y,/-/);
# 	split(DataVal["Time"],T,/:/);
# 	DataVal["UnixTime"]=unixtime(Y[1],Y[2],Y[3],T[1],T[2],T[3]);
#         }
# /^[[:digit:]][[:digit:]] LAT /{
# 	posout=parsepos($3 " " $4);
# 	if (POS_FORMAT~/[Mm]/){
# 		if (posout<0){posout=-posout; H="S"}else{H="N"};
# 		posout=posddm(posout) H
# 		}
# 	DataVal["Latitude"]=posout;
# 	}
# /^[[:digit:]][[:digit:]] LONG/{
# 	posout=parsepos($3 " " $4);
# 	if (POS_FORMAT~/[Mm]/){
# 		if (posout<0){posout=-posout; H="W"}else{H="E"};
# 		posout=posddm(posout) H
# 		}
# 	DataVal["Longitude"]=posout;
# 	}
# 
# /^[[:digit:]][[:digit:]] GRID/{ DataVal["Gridno"]=$3 }
# /^[[:digit:]][[:digit:]] STN /{ DataVal["Station"]=$3; DataVal["Cruise"]=$4;}
# /^[[:digit:]][[:digit:]] SPD /{ DataVal["Log"]=$3 }
# /^[[:digit:]][[:digit:]] DPTH/{ DataVal["Sounding"]=$3 }
# /^[[:digit:]][[:digit:]] HDG /{ DataVal["Heading"]=$3 }
# /^[[:digit:]][[:digit:]] SOG /{ DataVal["Speed"]=$3 }
# /^[[:digit:]][[:digit:]] COG /{ DataVal["Course"]=$3 }
# /^[[:digit:]][[:digit:]] SEAT/{ DataVal["SeaTemp"]=$3 }
# /^[[:digit:]][[:digit:]] SEAT/{ DataVal["Temperature"]=$3 }
# /^[[:digit:]][[:digit:]] SAL /{ DataVal["Salinity"]=$3 }
# /^[[:digit:]][[:digit:]] FLUO/{ DataVal["Fluor"]=$3 }
# /^[[:digit:]][[:digit:]] LGHT/{ DataVal["Light"]=$3 }
# /^[[:digit:]][[:digit:]] AIRP/{ DataVal["AirPress"]=$3 } 
# /^[[:digit:]][[:digit:]] AIRT/{ DataVal["AirTemp"]=$3 }
# /^[[:digit:]][[:digit:]] HUM /{ DataVal["Humidity"]=$3 }
# /^[[:digit:]][[:digit:]] WSTK/{ DataVal["WndSpdTK"]=$3 }
# /^[[:digit:]][[:digit:]] WSTM/{ DataVal["WndSpdTM"]=$3 }
# /^[[:digit:]][[:digit:]] WDT /{ DataVal["WindDirT"]=$3 }
# /^[[:digit:]][[:digit:]] WSRK/{ DataVal["WndSpdRK"]=$3 }
# /^[[:digit:]][[:digit:]] WSRM/{ DataVal["WndSpdRM"]=$3 }
# /^[[:digit:]][[:digit:]] WDR /{ DataVal["WindDirR"]=$3 }
# /^[[:digit:]][[:digit:]] HYWO/{ DataVal["HydWO"]=$3 }
# /^[[:digit:]][[:digit:]] HYWS/{ DataVal["HydWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] HYWL/{ DataVal["HydWLd"]=$3 }
# /^[[:digit:]][[:digit:]] BTWO/{ DataVal["BioWO"]=$3 }
# /^[[:digit:]][[:digit:]] BTWS/{ DataVal["BioWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] BTWL/{ DataVal["BioWLd"]=$3 }
# /^[[:digit:]][[:digit:]] LTWO/{ DataVal["LTWO"]=$3 }
# /^[[:digit:]][[:digit:]] LTWS/{ DataVal["LTWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] LTWL/{ DataVal["LTWLd"]=$3 }
# /^[[:digit:]][[:digit:]] SHWO/{ DataVal["SHWO"]=$3 }
# /^[[:digit:]][[:digit:]] SHWS/{ DataVal["SHWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] SHWL/{ DataVal["SHWLd"]=$3 }
# /^[[:digit:]][[:digit:]] MPWO/{ DataVal["MPWO"]=$3 }
# /^[[:digit:]][[:digit:]] MPWS/{ DataVal["MPWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] MPWL/{ DataVal["MPWLd"]=$3 }
# /^[[:digit:]][[:digit:]] MSWO/{ DataVal["MSWO"]=$3 }
# /^[[:digit:]][[:digit:]] MSWS/{ DataVal["MSWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] MSWL/{ DataVal["MSWLd"]=$3 }

BEGIN{FS=","
	OutPutList="Date,Time,Latitude,Longitude,SeaTemp,Salinity";
	if (ENVIRON["DDSLIST"]~","){OutPutList=ENVIRON["DDSLIST"]};
	if (ARGV[1]~","){
		OutPutList=ARGV[1];
		delete ARGV[1];
		} else {
		if (ARGV[1]~/help/){
		# Print entire recognised list

			print "Some variable names recognised are: "
			print " Gridno\n Station\n Cruise\n Log\n Sounding\n Heading\n Speed\n Course\n SeaTemp\n Temperature\n Salinity\n Fluor\n Light\n AirPress \n AirTemp\n Humidity\n WndSpdTK\n WndSpdTM\n WindDirT\n WndSpdRK\n WndSpdRM\n WindDirR\n HydWO\n HydWSpd\n HydWLd\n BioWO\n BioWSpd\n BioWLd\n LTWO\n LTWSpd\n LTWLd\n SHWO\n SHWSpd\n SHWLd\n MPWO\n MPWSpd\n MPWLd\n MSWO\n MSWSpd\n MSWLd\n "
			exit;

			}
		}
# parse the output variable list
	N=split(OutPutList,OutPutVars,",");
# make a format string
	for (n in OutPutVars){ 
		fmt[n]="%8g%s"; hfmt[n]="%8s%s";
	if (	OutPutVars[n]~"Time"||
		OutPutVars[n]~"Latitude"||
		OutPutVars[n]~"Longitude"||
		OutPutVars[n]~"Station"||
		OutPutVars[n]~"Grid"){
		fmt[n]="%8s%s" }
	if (	OutPutVars[n]~"Date"){
		fmt[n]="%10s%s"; hfmt[n]="%10s%s"}
	if (	PRINT_HEADER && (OutPutVars[n]~"Latitude"|| OutPutVars[n]~"Longitude")){
		fmt[n]="%12s%s"; hfmt[n]="%12s%s"}
		}
	OFMT="%.7g"
	}
{ gsub("\"",""); gsub("","") }
FNR==1{print FILENAME > "/dev/stderr" }
/^id/{ 
	# identifies a header - determine input vars
	for (N=1;N<=NF;N++){
		VN[N]=$N
		# print VN[N]
		}
	if (PRINT_HEADER){ 
			if (NRECS++%HEADER_SKIP==0){
  				for (i=1;i<=N;i++){printf hfmt[i], OutPutVars[i],OFS}; 
				printf "\n"
			}
	}
	}
!/^id/{
	for (N=1;N<=NF;N++){IV[VN[N]]=$N}
	# 2016-08-22 12:00:00
	DataVal["RawDate"]=IV["TIME_SERVER"]
	DataVal["Time"]=substr(DataVal["RawDate"],12,8);
	year=substr(DataVal["RawDate"],1,4);
	month=substr(DataVal["RawDate"],6,2);
	day=substr(DataVal["RawDate"],9,2);
	DataVal["Date"]=year "-" month "-" day;
	DataVal["BadDate"]=month "/" day "/" year;
	# print DataVal["Date"],DataVal["Time"]
	split(DataVal["Date"],Y,/-/);
	split(DataVal["Time"],T,/:/);
	DataVal["UnixTime"]=unixtime(Y[1],Y[2],Y[3],T[1],T[2],T[3]);
# 	print DataVal["UnixTime"]
# 	posout=parsepos($3 " " $4);
# 	if (POS_FORMAT~/[Mm]/){
# 		if (posout<0){posout=-posout; H="S"}else{H="N"};
# 		posout=posddm(posout) H
# 		}
	inLat=IV["LATITUDE"] 
	DataVal["Latitude"]=int(inLat/100) ":" inLat%100 IV["N_S"]
	# # printf "%.5f\n",parsepos(DataVal["Latitude"])
	# print parsepos(DataVal["Latitude"])
	inLon=IV["LONGITUDE"] 
	DataVal["Longitude"]=int(inLon/100) ":" inLon%100 IV["E_W"]
	# # printf "%.5f\n",parsepos(DataVal["Longitude"])
	# print parsepos(DataVal["Longitude"])
# /^[[:digit:]][[:digit:]] GRID/{ DataVal["Gridno"]=$3 }
# /^[[:digit:]][[:digit:]] STN /{ DataVal["Station"]=$3; DataVal["Cruise"]=$4;}
# /^[[:digit:]][[:digit:]] SPD /{ DataVal["Log"]=$3 }
# /^[[:digit:]][[:digit:]] DPTH/{ DataVal["Sounding"]=$3 }
# /^[[:digit:]][[:digit:]] HDG /{ DataVal["Heading"]=$3 }
# /^[[:digit:]][[:digit:]] SOG /{ DataVal["Speed"]=$3 }
# /^[[:digit:]][[:digit:]] COG /{ DataVal["Course"]=$3 }
	DataVal["SeaTemp"]=IV["TSG_TEMP"]
	DataVal["Temperature"]=IV["TSG_TEMP"]
	# "TSG_COND",,,
	DataVal["Salinity"]=IV["TSG_SALINITY"]
# /^[[:digit:]][[:digit:]] FLUO/{ DataVal["Fluor"]=$3 }
# /^[[:digit:]][[:digit:]] LGHT/{ DataVal["Light"]=$3 }
# /^[[:digit:]][[:digit:]] AIRP/{ DataVal["AirPress"]=$3 } 
# /^[[:digit:]][[:digit:]] AIRT/{ DataVal["AirTemp"]=$3 }
# /^[[:digit:]][[:digit:]] HUM /{ DataVal["Humidity"]=$3 }
# /^[[:digit:]][[:digit:]] WSTK/{ DataVal["WndSpdTK"]=$3 }
# /^[[:digit:]][[:digit:]] WSTM/{ DataVal["WndSpdTM"]=$3 }
# /^[[:digit:]][[:digit:]] WDT /{ DataVal["WindDirT"]=$3 }
# /^[[:digit:]][[:digit:]] WSRK/{ DataVal["WndSpdRK"]=$3 }
# /^[[:digit:]][[:digit:]] WSRM/{ DataVal["WndSpdRM"]=$3 }
# /^[[:digit:]][[:digit:]] WDR /{ DataVal["WindDirR"]=$3 }
# /^[[:digit:]][[:digit:]] HYWO/{ DataVal["HydWO"]=$3 }
# /^[[:digit:]][[:digit:]] HYWS/{ DataVal["HydWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] HYWL/{ DataVal["HydWLd"]=$3 }
# /^[[:digit:]][[:digit:]] BTWO/{ DataVal["BioWO"]=$3 }
# /^[[:digit:]][[:digit:]] BTWS/{ DataVal["BioWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] BTWL/{ DataVal["BioWLd"]=$3 }
# /^[[:digit:]][[:digit:]] LTWO/{ DataVal["LTWO"]=$3 }
# /^[[:digit:]][[:digit:]] LTWS/{ DataVal["LTWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] LTWL/{ DataVal["LTWLd"]=$3 }
# /^[[:digit:]][[:digit:]] SHWO/{ DataVal["SHWO"]=$3 }
# /^[[:digit:]][[:digit:]] SHWS/{ DataVal["SHWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] SHWL/{ DataVal["SHWLd"]=$3 }
# /^[[:digit:]][[:digit:]] MPWO/{ DataVal["MPWO"]=$3 }
# /^[[:digit:]][[:digit:]] MPWS/{ DataVal["MPWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] MPWL/{ DataVal["MPWLd"]=$3 }
# /^[[:digit:]][[:digit:]] MSWO/{ DataVal["MSWO"]=$3 }
# /^[[:digit:]][[:digit:]] MSWS/{ DataVal["MSWSpd"]=$3 }
# /^[[:digit:]][[:digit:]] MSWL/{ DataVal["MSWLd"]=$3 }
	for (i=1;i<=N-1;i++){ printf fmt[i],DataVal[OutPutVars[i]],OFS } ; 
	printf fmt[i],DataVal[OutPutVars[N]],ORS;
	for (i in OutPutVars){DataVal[OutPutVars[i]]=""};
	printf "\n"
	fflush();
	}



