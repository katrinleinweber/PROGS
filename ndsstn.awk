BEGIN{
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
