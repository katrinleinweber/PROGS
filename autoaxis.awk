#
# Usage: echo <Range> | gawk -f axis.awk 
# Creates a string to use in -B with logical axis markings
#
BEGIN{
# 	split("0.000025,0.00005,0.0001,0.00025,0.0005,0.001,0.0025,0.005,0.01,0.025,0.05,0.1,0.25,0.5,1,2.5,5,10,25,50,100,250,500,1000,2500,5000,10000,25000,50000,10000",dd,",");
 	split("1,2,2.5,5",dd,",");
	lim=6;
	}
{	gsub("/"," ")}
{	
	D=$2-$1;

	m=int(log(D/dd[4])/log(10));

	dx=D/(10^m);
	i=1;
	while (int(dx/dd[i])>lim){i++}
	ax=2*dd[i-1]*10^m; fx=dd[i-1]*10^m;
	
	D=$4-$3;
	m=int(log(D/dd[4])/log(10));
	dy=D/(10^m);
	i=1;
	while (int(dy/dd[i])>lim){i++}
	ay=dd[i+1]*10^m; fy=dd[i-1]*10^m;
	print "f" fx "a" ax "/f" fy "a" ay
}


