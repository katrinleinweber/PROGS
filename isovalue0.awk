# extracts isovalue from s87 ctd data file
#
# SA TE PR
# para = parameter to find value [TE]
# valu = valu of parameter [10]
function abs(x){
	if (x<0){return -x} else {return x}
	}
function OutputResult(){
	print Stn,Lat,Lon,item;
	}
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
	next;
	}
Data==1{
	for (i=1;i<=N;i++){V[vars[i]]=$i};
	testV=abs(V[para]-valu);
	if (testV<min){
		min=testV; 
		item=$0;
		}
	}
END{
	OutputResult()
	}

