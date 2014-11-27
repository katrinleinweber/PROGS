# extracts isovalue from s87 ctd data file
#
# SA TE PR
# para = parameter to find value [TE]
# valu = valu of parameter [10]

function abs(x){
	if (x<0){return -x} else {return x}
	}
function OutputResult(){
	printf "%g %g %g ",Stn,Lat,Lon
	for (i=1;i<=N;i++){printf "%s ",Res[vars[i]]};
	printf "\n";
	}
function InterPol(v0,v1,p1,v2,p2){
	return p1+(p2-p1)*(v0-v1)/(v2-v1)
	}

function sign(x){ return x<0?-1:x==0?0:1 }

BEGIN{ 
# defaults
	para="TE"; valu=10; 
	first=1;
	}
/^C/{
	if (!first){ OutputResult() } else {first=0};
	Stn=$2; Lat=$4; Lon=$5;
	testV=1e6; item="NaN"; min=testV; 
	Data=0;
	}
/^@/{
	sub("@",""); gsub("  "," "); gsub(" ","\t"); 
	N=split(toupper($0),vars,"\t");
	Data=1;
	for (i=1;i<=N;i++){Res[vars[i]]="NaN"};
	next;
	}

Data==2{

	# a=$0
	# v= v1= v2=
	# R=interp each a on p
	# p=a

	for (i=1;i<=N;i++){Cur[vars[i]]=$i};
	if (sign(Cur[para]-valu) != sign(Pre[para]-valu)){

	for (i in Cur){
	Res[i]=InterPol(valu,Pre[para],Pre[i],Cur[para],Cur[i]); }
	}
	for (i in Cur){Pre[i]=Cur[i]};
	}

Data==1{ for (i=1;i<=N;i++){Pre[vars[i]]=$i}; Data=2}
END{
	OutputResult()
	}

