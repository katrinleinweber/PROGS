#
# GAWK function: 
#	input: data table
#		eg. columns of
#		   lat long temp salt oxy
# 	output minimum and maximum for each column  
#		eg.
#		    max(lat) long temp salt oxy  (at maximum lat) 
#		    min(lat) long temp salt oxy  (at minimum lat) 
#		    lat max(long) temp salt oxy  (at maximum long) 
#		    lat min(long) temp salt oxy  (at minimum long) 
#		    lat long max(temp) salt oxy  (at maximum temp) 
#		    lat long min(temp) salt oxy  (at minimum temp) 
#		etc...
#
BEGIN{
	OFS="\t"
	first=1
	}
/^[[:space:]]*#/{
	print; next
	}
first {
	first=0;
	for (i=1;i<=NF;i++) {
		max[i]=$i;
		min[i]=$i; 
		dmax[i]=$0;
		dmin[i]=$0;
		if ($i<-999){ min[i]=-$i}
		}
	}
{
	for (i=1;i<=NF;i++) {
		if ($i>max[i]){dmax[i]=$0; max[i]=$i};
		if ($i<min[i]&&$i>-999){dmin[i]=$0; min[i]=$i};
		}
	}
END{	for (i=1;i<=NF;i++ ){
		print dmax[i],"max_" i; 
		print dmin[i],"min_" i
		}
	}

