# calculates density  for s87 files
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

	if (column["SA"]!=0 && column["TE"]!=0 && column["PR"]!=0){
		calcdep=1;
		print "# " TimeStr ": sw_ptmp: Calculate potential temperature"
		print "# " TimeStr ": sw_dens: Calculate sigma-theta"
		cols++;
		param[cols]="PT";
		column[param[cols]]=cols;
		$0=$0 "\tPT"
		cols++;
		param[cols]="S0";
		column[param[cols]]=cols;
		$0=$0 "\tS0"
		} else {calcdep=0}

	print "@" toupper($0)
	getline
}
data{  
	if (calcdep){
		if ($column["SA"]>-9 && $column["TE"]>-9 && $column["PR"]>-9){
		$column["PT"]=sw_ptmp($column["SA"],$column["TE"],$column["PR"],0);
		$column["S0"]=sw_dens($column["SA"],$column["PT"],0)-1000;
		}
		else
		{$column["PT"]=-9999;$column["S0"]=-9999}
		}
	for (i=1;i<cols;i++){printf "%g\t",$column[toupper(param[i])]};
	printf "%g\n",$column[toupper(param[i])];
	}
	

