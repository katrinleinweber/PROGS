BEGIN{
	fn=tolower(fn);

	split(fn,hn,".");
	dhn=hn[1] ".hdr"
	sub("rs50.","rs50d",dhn);

	bfn=hn[1] ".btl"
	sub("rs50.","rs50u",bfn);

	uhn=hn[1] ".hdr"
	sub("rs50.","rs50u",uhn);

	sub("rs50.","rs50?",fn);
	sub("\\..*",".*",fn);

	tempfile=hn[1] ".$$$"

	bakfile=hn[1] ".bak"
	sub("rs50.","rs50u",bakfile);

	print "Reading " dhn

	while (getline < dhn){
		if (/ Sta.#/){ 
			staline=$0
			stn=$0;sub("\.*Sta.#: *","",stn);sub("[ |].*","",stn)
			}
		if (/Vessel/){ vline=$0 }
		if (/Date/){ dateline=$0 }
		if (/St.Long/){ longline=$0 }
		if (/St.Lat/){ latline=$0 }
		if (/Depth/){
			i=index($0,":");j=index($0,"|");
			depthstr=substr($0,i,j-i)
			}
		}
	close(dhn)

	print "Changing " uhn

	while (getline < uhn){

		if (/ Sta.#/){ $0=staline }
		if (/Vessel/){ $0=vline }
		if (/Date/){ $0=dateline }
		if (/St.Long/){ $0=longline }
		if (/St.Lat/){ $0=latline }
		if (/Depth/){ 
			i=index($0,":");j=index($0,"|");
			depthline=substr($0,1,i-1) depthstr substr($0,j)
			$0=depthline
			}
		print > tempfile
		}
	close(uhn)
	close(tempfile)
	system("del " uhn );
	system("ren " tempfile " " uhn); 

	print "Changing " bfn

	while (getline < bfn){

		if (/ Sta.#/){ $0=staline }
		if (/Vessel/){ $0=vline }
		if (/Date/){ $0=dateline }
		if (/St.Long/){ $0=longline }
		if (/St.Lat/){ $0=latline }
		if (/Depth/){ 
			i=index($0,":");j=index($0,"|");
			depthline=substr($0,1,i-1) depthstr substr($0,j)
			$0=depthline
			}
		print > tempfile

		}

	close(bfn)
	close(tempfile)
	system("del " bakfile)
	system("ren " bfn " " bakfile)
	system("ren " tempfile  " " bfn )

# }
#	print "Creating " stn ".zip"

#	system("pkzip -mu -ex " stn ".zip " fn)
	}
