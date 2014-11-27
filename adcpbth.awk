#
# adcpbth.awk reads data from averaged RDI files (.bth files) 
# and prints out to .dat file
# 		for processing with calcadcp.m
BEGIN{
	mo="Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec";
	n=split(mo,MO,",");
	}
# Convert DOS files
{ gsub(//,"") }
# Use the line of --s to indicate end of data
/------/{data=0; average=0 }
/AVERAGE/{average=1}
# Parse the time string
/ENSEMBLE TIME/{
	match($0,/:/);
	DD=substr($0,RSTART+1);
	gsub(/^ */,"",DD);
	gsub(/ *$/,"",DD);
	DD=gensub(/:(.):/,":0\\1:",g,DD);
	DD=gensub(/ (.):/," 0\\1:",g,DD);
	DD=gensub(/:(.)$/,":0\\1",g,DD);
	n=split(DD,dd,"/");
	DD=dd[1] " " MO[dd[2+0]+0] " " dd[3];
	express="date -d \"" DD "\" +%s"
	express | getline UnixTime
	close(express);
	}
# Parse the position strings
/Lat.*tude/{
	match($0,/:/);
	Lat=substr($0,RSTART+1)+0;
	}
/Long.*tude/{
	match($0,/:/);
	Lon=substr($0,RSTART+1)+0;
	}
# Take the ships speed from  the header information
/SPEED/{
	Vspd=$4
	}
/DIR:/{
	Vdir=$2
	}
/HEADING:/{
	Vhead=$2
	}
# Ships speed from the navigation device
/Vel E\/W:/{
	NavEW=$4
	}
/Vel N\/S:/{
	NavNS=$3
	}
# This is the column identifier line. Use it to indicate begin of data
/Bin.*Good/&&!average{
	getline;getline;
	data=1;
	}
# If it has an error, change it to a NaN
/Error/{
	gsub(/Error/,"NaN");
	}
# If it's data then write it out
# Following the header info are binnum,bindepthfrom,bindepthto, binvelew, binvelns, binvelmag, binveldir, binvelver, binvelerr, Amp?, percentgd

data&&!/invalid/&&NF>=1{
# Vspd and Vdir must be converted to VEW and VNS
	VNS=Vspd*cos(Vdir*pi()/180); VEW=Vspd*sin(Vdir*pi()/180); 
	# print UnixTime,Vspd,Vdir,Vhead,NavEW,NavNS,Lat,Lon,$0
	print UnixTime,VEW,VNS,Vhead,NavEW,NavNS,Lat,Lon,$0
	}

