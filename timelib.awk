
function day2date(string,
		YD,yr,dim,mo,sa,dat){
	split("0 31 28 31 30 31 30 31 31 30 31 30 31",dim);
	split( string, YD );
	if ( YD[1]<100 ) { YD[1] += 1900 } ;
	yr = YD[1]%100 ;
	if ( yr==0 ) { yr = int(YD[1]/100) }; 
	if ( yr%4==0 ) { dim[3] = 29 };
	mo = 1; 
	da = YD[2]; 
	while ( da > dim[mo+1] ) { da -= dim[++mo] };
	dat = sprintf("%04d %02d %02d", YD[1],mo,da );
	return dat
	}

function abs(x){return x<0?-x:x}

# function abs(x){
#	if (x<0){return -x} else {return x};
#	}

function pi(){ return 4*(4*atan2(1,5)-atan2(1,239)) }

function distance(lat1,lon1,lat2,lon2,
		d,dlon,dlat,a,c){
	lat1=lat1/180*pi();
	lon1=lon1/180*pi();
	lat2=lat2/180*pi();
	lon2=lon2/180*pi();
	dlon = lon2 - lon1;
	dlat = lat2 - lat1;
	a = sin(dlat/2)^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2; 
	c = 2 * atan2( sqrt(a), sqrt(1-a) ); 
	if (c < 0) { c = pi() + c };
	d = 6367 * c;
	return d
	} 
