#!/bin/gawk -f
BEGIN{
#	NBin["Salt"][base] goes from 0 to maximum salt in steps of 0.1 (about 400 potential bins)
#	NBin["Temp"][base] simly

	Binsize=0.1

	Limit["Salt"]=0.1;
	Limit["Salt"]=0.5;
	Limit["Temp"]=0.5;
	Limit["Lati"]=0.01;
	Limit["Long"]=0.01;

#	Title["Date"]="Date";
	Title["Unix"]="Unix Timestamp";
	Title["Long"]="Longitude";
	Title["Lati"]="Latitude";
	Title["Salt"]="Salinity";
	Title["Temp"]="Temperature";

	for ( i in Title ){
		Max[i]=-1e93; Min[i]=1e93; Sum[i]=0; Num[i]=0;
		}

	printf "==============================================================================\n"
	printf "                         DDS Validation Report\n"
	printf "==============================================================================\n"
	printf "\n"
	for ( i in Limit ){ printf "%12s step = %g \n",Title[i],Limit[i]}
	printf "\n"

	}

{	Now["Date"]=$1;
	Now["Time"]=$2; sub(/:00$/,"",Now["Time"]);
	Now["Unix"]=$3;
	Now["Lati"]=parsepos($4);
	Now["Long"]=parsepos($5);
	Now["Salt"]=$6; NBinSalt[int(Now["Salt"]/Binsize)]++;
	Now["Temp"]=$7; NBinTemp[int(Now["Temp"]/Binsize)]++;
	for ( i in Now ){ Diff[i]=Now[i]-Prev[i];}
	}

NR==1{
	First["Date"]=Now["Date"]; First["Time"]=Now["Time"]; 
	}

NR!=1{ if ( Diff["Unix"]>60 || Diff["Unix"]<=0 ){
	deltaT=Diff["Unix"]/60 " min";
		printf "-\nTime gap: %-8s Time jumps from %s %s to %s %s\n-\n",	\
			deltaT,Prev["Date"],Prev["Time"],Now["Date"],Now["Time"];
		}
	for ( i in Diff ){
		if ( i!="Unix" && i!="Time" && i!="Date"){
			if ( abs(Diff[i])>Limit[i] ){
				printf "%12s step:    %7.3f from %s %s to %s %s\n", \
					Title[i],Diff[i],Prev["Date"],Prev["Time"],Now["Date"],Now["Time"];
				}
			}
		}
	}
	
{	for ( i in Now ){
		Prev[i]=Now[i];
		if (Now[i]>Max[i]){Max[i]=Now[i];}
		if (Now[i]<Min[i]){Min[i]=Now[i];}
		Sum[i]+=Now[i];
		Num[i]++;
		}

#	for ( i in Upper ){
#		if ( Now[i]>Upper[i] ){Nupper[i]++}
#		}
#	for ( i in Lower ){
#		if ( Now[i]<Lower[i] ){Nlower[i]++}
#		}
	
	}
END{
	for (i in Now){Last[i]=Now[i]}
	printf "==============================================================================\n"
	printf "%d records processed, from %s %s to %s %s\n",\
		NR,First["Date"],First["Time"],Last["Date"],Last["Time"];
	printf "\n"


	printf "           %16s     %16s  %16s\n","Minimum","Maximum","Mean"
	printf "%11s:     %16s     %16s\n",
		"Date",strftime("%Y-%m-%d %H:%M",Min["Unix"]),strftime("%Y-%m-%d %H:%M",Max["Unix"])
	for ( i in Title ){
		if ( i != "Unix" ){printf "%11s:  %13s     %16s  %16s\n",Title[i],Min[i],Max[i],Sum[i]/Num[i]}
		}
#	for ( i in Upper ){printf "%d records %s greater than %g\n",Nupper[i],Title[i],Upper[i];} 
#	for ( i in Lower ){printf "%d records %s less than %g\n",Nlower[i],Title[i],Lower[i];} 
	
	printf "\n"

	for ( i in NBinTemp ){ printf "%12s: (%05.2f <= T < %05.2f) = %7d records\n",Title["Temp"],i*Binsize,i*Binsize+Binsize,NBinTemp[i] | "sort -n" }
	close( "sort -n" )
	printf "\n"

	for ( i in NBinSalt ){ printf "%12s: (%05.2f <= S < %05.2f) = %7d records\n",Title["Salt"],i*Binsize,i*Binsize+Binsize,NBinSalt[i] | "sort -n" }
	close( "sort -n" )
	
	}

# vi: se tw=0 :

