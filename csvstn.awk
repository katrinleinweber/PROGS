#
# parse csv station file from nds
#
# syntax:
#
#    1  , 2 ,   3   ,  4   ,  5 , 6  , 7  ,  8 ,  9 ,   10     ,  11   
# Vessel,Voy,Station,Status,Grid,Date,Time,Lati,Long,Activities,Comment
#
#

BEGIN{ FS=","
	OFS="\t"
	}
{sub(//,"")}

$4~/OPEN/{
	Open["Station"]=$3;
	Open["Grid"]=$5; gsub(/ /,"_",Open["Grid"]);
	split($6,D,"/"); Open["Date"]=sprintf("%4d/%02d/%02d",D[3],D[2],D[1]);
	split($7,T,":"); Open["Time"]=sprintf("%02d:%02d:%02d",T[1],T[2],T[3]);
#	cmd="date -d \"" Open["Date"] " " Open["Time"] "\" +%s" 
#	cmd | getline Open["Timestamp"]
#	close(cmd)
	Open["Latitude"]=parsepos($8);
	Open["Longitude"]=parsepos($9);
	ActionIntent=$10
}
$4~/CLOSE/{
	Close["Station"]=$3;
	Close["Grid"]=$5; gsub(/ /,"_",Close["Grid"]);
	split($6,D,"/"); Close["Date"]=sprintf("%4d/%02d/%02d",D[3],D[2],D[1]);
	split($7,T,":"); Close["Time"]=sprintf("%02d:%02d:%02d",T[1],T[2],T[3]);
#	cmd="date -d \"" Close["Date"] " " Close["Time"] "\" +%s" 
#	cmd | getline Close["Timestamp"]
#	close(cmd)
	Close["Latitude"]=parsepos($8);
	Close["Longitude"]=parsepos($9);
	ActionComplete=$10
	print Open["Latitude"],Open["Longitude"],Open["Station"],Open["Grid"],Open["Date"],Close["Time"],ActionComplete
	OFS="\t"
}
