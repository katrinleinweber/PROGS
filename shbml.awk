# find closest SHBML station

BEGIN{
	OFS="\t";
	# load SHBML positions
	# StationFile=ENVIRON["HOME"] "/PROGS/stationpos.txt"
	StationFile=ENVIRON["HOME"] "/PROGS/stationpos.txt"
	i=0;
	while ( getline < StationFile ){
		if (!/^#/){
			i++
			lat[i]=$1;
			lon[i]=$2;
			}
		# print;
		}
	print "#FILE\tSTN\tGRD\tLAT\tLON\tDIST\tSHBMLLAT\tSHBMLLON\tSHBML"
	}

# read a position (from header line of s87 file)
# !/^#/{
FNR==1{
	la=$4; lo=$5;
	dmin=1e4;
  # Calculate how close to each
	for (i in lat){
		d[i]=distance(la,lo,lat[i],lon[i]);
		# print d[i] , lat[i], lon[i], i | "sort -n"
  # find the closest 
		if (d[i]<dmin){dmin=d[i]; dind=i;};
		}
  # print the info
	print FILENAME,$2,$3,la,lo, d[dind] , lat[dind], lon[dind], dind | "sort -k6 -n" 

	}
  
