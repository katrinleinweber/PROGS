BEGIN{ FS="\t"
	OFS="\t"
	}
{sub("","")}

$7~"open"{
	split($1,S); Open["Station"]=S[1];
	Open["Grid"]=$2;
	split($3,D,"/"); Open["Date"]=sprintf("%4d/%02d/%02d",D[3],D[2],D[1]);
	split($4,T,":"); Open["Time"]=sprintf("%02d:%02d:%02d",T[1],T[2],T[3]);
	cmd="date -d \"" Open["Date"] " " Open["Time"] "\" +%s" 
	cmd | getline Open["Timestamp"]
	close(cmd)
	Open["Latitude"]=parsepos($5);
	Open["Longitude"]=parsepos($6);
	getline ActionIntent
}
$7~"close"{
	split($1,S); Close["Station"]=S[1];
	Close["Grid"]=$2;
	split($3,D,"/"); Close["Date"]=sprintf("%4d/%02d/%02d",D[3],D[2],D[1]);
	split($4,T,":"); Close["Time"]=sprintf("%02d:%02d:%02d",T[1],T[2],T[3]);
	cmd="date -d \"" Close["Date"] " " Close["Time"] "\" +%s" 
	cmd | getline Close["Timestamp"]
	close(cmd)
	Close["Latitude"]=parsepos($5);
	Close["Longitude"]=parsepos($6);
	getline ActionComplete
}
/^$/{
#	print Open["Latitude"],Open["Longitude"],Open["Station"],Open["Grid"],Open["Date"],Open["Time"],Close["Date"],Close["Time"]}
	print Open["Latitude"],Open["Longitude"],Open["Station"],Open["Grid"],Open["Timestamp"],Close["Timestamp"],ActionComplete
	OFS="\t"
	}
{sub("","")}
{
	Station=$2;
	Grid=$4;
	State=toupper($3);

	split($5,D,"/"); Date=sprintf("%4d/%02d/%02d",D[3],D[2],D[1]);
	split($6,T,":"); Time=sprintf("%02d:%02d:%02d",T[1],T[2],T[3]);
	Latitude=parsepos($7 ":" $8);
	Longitude=parsepos($9 ":" $10);
	if (State~/OPEN/){print Latitude,Longitude,Station,Grid,Date,Time}
}
