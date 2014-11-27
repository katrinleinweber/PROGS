BEGIN{ FS="\t"
	OFS="\t"
	}
{sub("","")}
{
	split($1,S); Station=S[1];
	Grid=$2;
	split($3,D,"/"); Date=sprintf("%4d/%02d/%02d",D[3],D[2],D[1]);
	split($4,T,":"); Time=sprintf("%02d:%02d:%02d",T[1],T[2],T[3]);
	Latitude=parsepos($5);
	Longitude=parsepos($6);
	State=$7;
	if (State~"open"){print Latitude,Longitude,Station,Grid,Date,Time}
}
