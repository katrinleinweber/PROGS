#! /usr/bin/gawk  -f 
# s872table -	Reads s87 format files and output STP data table
####
####
#
#  ACHTUNG, ACHTUNG!!!
#
#  value function takes a column number and returns an error value or the value
#  associated with that column
#
####
#
BEGIN{
	OFS="\t"
	ErrorValue=-9
# default output variable list
        OutPutList="Date,Time,Latitude,Longitude,Pressure,Temperature,Salinity";
# examine the environment variable
        if (ENVIRON["DDSLIST"]~","){OutPutList=ENVIRON["DDSLIST"]};
# examine the command line
        if (ARGV[1]~","){OutPutList=ARGV[1]; delete ARGV[1]};
# parse the output variable list
        N=split(OutPutList,OutPutVars,",");
# make a format string
        for (n in OutPutVars){
                if (    OutPutVars[n]~"Filename"||
			OutPutVars[n]~"Date"||
                        OutPutVars[n]~"Time"||
                        OutPutVars[n]~"Latitude"||
                        OutPutVars[n]~"Longitude"||
                        OutPutVars[n]~"LatDM"||
                        OutPutVars[n]~"LonDM"||
                        OutPutVars[n]~"Station"||
                        OutPutVars[n]~"Type"||
                        OutPutVars[n]~"Grid")
			{ fmt[n]="%s%s"} 
		else {fmt[n]="%g%s"}; 
        }
	printf "#"
	for (i=1;i<=N-1;i++){printf "%s%s",OutPutVars[i],OFS}
	printf "%s%s",OutPutVars[i],ORS

}

function nvalue( num ){
	return num==""?ErrorValue:num
}

function value( col ){
	return col==""||col==0?ErrorValue:$col
}

# fix dos file in unix environment
{ gsub("","") }
# extract lat and long from s87 header line
FNR==1{	Data=0;
	cols=0;
	for (i in column){column[i]=0}
	DataVal["Filename"]=FILENAME;
	DataVal["Type"]=substr($1,1,1);
	DataVal["Station"]=$2;
	DataVal["Grid"]=$3;
	DataVal["Latitude"]=$4;
	DataVal["LatDM"]=posddm($4,$4>=0?"N":"S");
	DataVal["Longitude"]=$5;
	DataVal["LonDM"]=posddm($5,$5>=0?"E":"W");
# Parse the date and time
	DataVal["Date"]=$6;
	day=$7;
	DataVal["Time"]=$8;
	datecmd="date -d \"" DataVal["Date"] " " DataVal["Time"] "\" \"+%s\""
	datecmd | getline DataVal["UnixTime"]
	close(datecmd)
# Set some default numbers that may not be initialized otherwise
	DataVal["Altitude"]=ErrorValue
	DataVal["Bathymetry"]=ErrorValue
#	for (n=1;n<=N;n++){print OutPutVars[n],DataVal[OutPutVars[n]]}
for (n in OutPutVars){
 if (    OutPutVars[n]~"Distance"){
  if (DataVal["Distance"]==""){
		DataVal["Distance"]=0
		Plat=DataVal["Latitude"]
		Plon=DataVal["Longitude"]
		}
  else {
		DataVal["Distance"]+=distance(\
			DataVal["Latitude"],DataVal["Longitude"],Plat,Plon,"km")
		Plat=DataVal["Latitude"]
		Plon=DataVal["Longitude"]
	}
   }
}
}

/^&.*ZM/{DataVal["Altitude"]=nvalue(gensub(/^.*ZM=([[:digit:]\.]*).*$/,"\\1",1,$0))}
/^&.*ZZ/{DataVal["Bathymetry"]=nvalue(gensub(/^.*ZZ=([[:digit:]\.]*).*$/,"\\1",1,$0))}
Data{
	DataVal["Temperature"]=value(column["TE"]);
	DataVal["BottleTemperature"]=value(column["RT"]);
	DataVal["PotentialTemp"]=value(column["PT"]);
	DataVal["SigmaTheta"]=value(column["S0"]);
	DataVal["Pressure"]=value(column["PR"]);
	DataVal["BottlePressure"]=value(column["RP"]);
	DataVal["Depth"]=value(column["DE"]);
	DataVal["Salinity"]=value(column["SA"]);
	DataVal["Conductivity"]=value(column["CO"]);
	DataVal["BottleSalinity"]=value(column["RS"]);
	DataVal["Oxygen"]=value(column["OX"]);
	DataVal["OxygenSat"]=value(column["OS"]);
	DataVal["OxygenVoltage"]=value(column["OC"]);
	DataVal["Fluorescence"]=value(column["FL"]);
	DataVal["Transmittance"]=value(column["TR"]);
	DataVal["Chlorophyll"]=value(column["CA"]);

        for (i=1;i<=N-1;i++){ printf fmt[i],DataVal[OutPutVars[i]],OFS };
        printf fmt[i],DataVal[OutPutVars[i]],ORS;
#         for (i=1;i<=N;i++){ print OutPutVars[i],DataVal[OutPutVars[i]] };
	

#	print lat,long,$column["PR"],$column["TE"],$column["SA"],$column["OX"],$column["FL"],$column["TR"];
	}
/^@/{	Data=1;
	sub("^@","");
	cols=split($0,param);
	for (i=1;i<=cols;i++){column[toupper(param[i])]=i};
	}

