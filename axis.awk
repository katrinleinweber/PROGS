#
# Usage: echo <Range> | gawk [-v PROJ=geographic|linear] -f axis.awk 
# Creates a string to use in -B with logical axis markings
BEGIN{
	if ( PROJ=="" ){ PROJ="l" }
	if ( PROJ~/l/ ){
		split("0.00002,0.00005,0.0001,0.0002,0.0005,0.001,0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50,100,200,500,1000,2000,5000,10000,20000,50000,10000",dd,",");
		}
	if ( PROJ~/g/){
		dd[1]=1/60;dd[2]=2/60;dd[3]=5/60;dd[4]=10/60;dd[5]=20/60;
		dd[6]=30/60;dd[7]=1;dd[8]=2;dd[9]=5;dd[10]=10;dd[11]=20;
		dd[12]=30;dd[13]=60;dd[14]=120;
		}
	lim=10
	}
{split($0,arr,"/")}
{	
	dx=(arr[2]-arr[1]); i=1;
	while (int(dx/dd[i])>lim){i++}
	ax=dd[i+1]; fx=dd[i-1];
	dy=(arr[4]-arr[3]); i=1;
	while (int(dy/dd[i])>lim){i++}
	ay=dd[i+1]; fy=dd[i-1];
	print "f" fx "a" ax "/f" fy "a" ay
}


