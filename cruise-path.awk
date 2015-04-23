#
# Work out time required for cruise from stations.
# file and path on command line
#
#  print "Usage: path.awk <COMMENT="comment">  \
#		<BD=bongodepth> <CTD=ctddepth|ottom> \
#		 STATIONSTRING stationfile
#
#  stationfile format
# lat long xxx xxx stn_num
#
# STATIONSTRING
# s1,s2,s3,s4,s5
#
BEGIN{
  OFS="\t"
  if (ARGV[1]!~","){
    print "Usage: path.awk <COMMENT=\"comment\"> <BD=bongodepth> <CTD=ctddepth|bottom> STATIONSTRING stationfile"; 
	crashing =1;
    exit
    }
  for (i in ARGV){ 
    if (ARGV[i]~/,/){
      if (length(STNS)==0){ STNS=ARGV[i]} else {STNS=STNS "," ARGV[i]; }
      delete ARGV[i] 
      }
    }
  COMMENT="# CTD to " CTD
  if (BD!=0){ COMMENT=COMMENT "; Bongo to " BD }
  n=split(STNS,S,",");
#
# Database of ports
  Slat["CT"]=parsepos("33 54.5 S");
  Slon["CT"]=parsepos("18 26.2 E");
  Slat["WB"]=parsepos("22 56.8 s");
  Slon["WB"]=parsepos("14 30 e");
  Slat["L"]=parsepos("26 38.56 s");
  Slon["L"]=parsepos("15 09.32 e");
  Slat["EL"]=parsepos("-33.0333333");
  Slon["EL"]=parsepos("27.9166667");
  Slat["PE"]=parsepos("33 58 S");
  Slon["PE"]=parsepos("025 36 E");
  Slat["D"]=parsepos("29 53.0 S");
  Slon["D"]=parsepos("31 00.0 E" );
  Slat["MB"]=parsepos("-34.1333333");
  Slon["MB"]=parsepos("22.1666667");
#
  PlanningDir="/eddy/home/duncombe/DOCS/DATACOLLECT/CRUISEPLANNING"
  if (CTD=="bottom"){ GridFile="fullcast.grd"} else {GridFile="shallow.grd"};
  StationTimes=PlanningDir "/" GridFile
  StationDepth=PlanningDir "/bathy.grd";

  N=0;
  TotT=0;

  }
!/^#/{
  Stn[++N]=$5
  Slat[Stn[N]]=$2
  Slon[Stn[N]]=$1
# look up the depth and calculate the station time requd
  comm="echo " $1 " " $2 "|grdtrack -G" StationTimes  
  comm | getline
  close(comm)
  Stime[Stn[N]]=$3
  Spos[Stn[N],1]=$2
  Spos[Stn[N],2]=$1
# look up depth at station posn
  comm="echo " $1 " " $2 "|grdtrack -G" StationDepth  
  comm | getline
  close(comm)
  Sdep[Stn[N]]=$3
}
END{
if (! crashing){
# print a report
print COMMENT
bar=   "----------------------------------------------------"
print bar



printf " Station     Latitude   Longitude   Depth(m)  Time(min)\n"
for (i=1;i<=N;i++){
# work out the total station time
printf "  %-8s  %9.4f  %9.4f      %5.0f    %3.0f\n",Stn[i],Spos[Stn[i],1],Spos[Stn[i],2],Sdep[Stn[i]],Stime[Stn[i]]
TotT+=Stime[Stn[i]];
} 

TotThr=TotT/60; TotTday=TotThr/24;

printf "\nTotal Time on Station = %.0f hrs (%.2f days)\n",TotThr,TotTday

print bar
Dist=0;

print " From          To       Distance(km)  Distance(n.m.)\n"

for (i=1;i<n;i++){ 
# work out dist from S[i] to S[i+1]
Dis[S[i+1]]=distance(Slat[S[i]],Slon[S[i]],Slat[S[i+1]],Slon[S[i+1]]);

Dist+=Dis[S[i+1]];
printf " %-8s    %-8s   %8.1f    %8.1f\n",S[i],S[i+1],Dis[S[i+1]],Dis[S[i+1]]/nmile()
# Slat[S[i]],Slon[S[i]],Slat[S[i+1]],Slon[S[i+1]];
}
Distnm=Dist/nmile();

printf "\nTotal Transit Distance = %5.0f km (%.0f n.m.)\n", Dist,Distnm
printf "%.0f n.m. @ 10 knots = %.0f hr (%.2f days)\n",Distnm,Distnm/10,Distnm/10/24 
print bar
printf "Total Cruise Time = %.2f + %.2f = %.2f days\n\f",TotTday,Distnm/10/24,TotTday+Distnm/10/24

}
}

