BEGIN{
	OFS="\t" 
	}
/Sta/{S=substr($0,11,6)}
/Lat/||/Long/{
	p=parsepos(substr($0,11,13))
	if (zone~/undetermined/){zone=$0~/Lat/?"latitude":"longitude"}
	p[zone]=p
#	print
	}
/----/{print p["latitude"],p["longitude"],S}


function abs(x){ return x<0?-x:x}
function parsepos(s,          sign,angle,a,n){
#
#  parse the latitude or longitude
#  recognizes any of the forms 
#	dd:mm:ss H
#	dd.dddd H
#	dd:mm.mmm H
#	dd mm ss H 
#  etc
#  returns the position in the form
#  -dd.dddd
#
	zone="undetermined"
	hemisphere="undetermined"
	d=1
	sign=1
	angle=0
	n=split(s,a,"[ :'""]")

	for (i=1;i<=n;i++) {
		if (a[i]!~/^$/){ 
			if (a[i]~/[EeWw]/){
				zone="longitude";
				hemisphere=substr(a[i],match(a[i],"[EeWw]"))
				}
			if (a[i]~/[NnSs]/){
				zone="latitude"
				hemisphere=substr(a[i],match(a[i],"[SsNn]"))
				}
			if (a[i]~/[SsWw]/){ sign=-1 }
			sub("[SsNnEeWw]","",a[i])
			angle+=a[i]/d
			d*=60
			}
		}
	return sign*angle
	}
