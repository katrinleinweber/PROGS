######################
######################
# This function obsolete - use and update s87depth
######################
#
# calculates depth pres for s87 files
BEGIN{
# initialize a marker
	data=0
# Set up some defaults
	OFS="\t"
	TimeStr=strftime("%Y-%m-%d %H:%M");
	}

FNR==1{Lati=$4}
data==0&&!/^@/{print}
/^@/{
	data=1;
	sub("^@","");
	cols=split($0,param);
	for (i=1;i<=cols;i++){column[toupper(param[i])]=i};

	if (column["DE"]==0 && column["PR"]!=0){
		calcdep=1;
		print "# " TimeStr ": sw_dpth: Calculate depth"
		cols++;
		param[cols]="DE";
		column[param[cols]]=cols;
		$0=$0 "\tDE"
		} else {calcdep=0}

	if (column["PR"]==0 && column["DE"]!=0){
		calcprs=1;
		print "# " TimeStr ": sw_pres: Calculate pressure"
		cols++;
		param[cols]="PR";
		column[param[cols]]=cols;
		$0=$0 "\tPR"
		} else {calcprs=0}

	print "@" toupper($0)
	getline
}
data{  
	if (calcdep){ $column["DE"]=sw_dpth($column["PR"],Lati); }
	if (calcprs){ $column["PR"]=sw_dpth($column["DE"],Lati); }
	for (i=1;i<cols;i++){printf "%g\t",$column[toupper(param[i])]};
	printf "%g\n",$column[toupper(param[i])];
	}
	

