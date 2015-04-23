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

	if (	column["SA"]!=0 && \
	   ( column["TE"]!=0 || column["PT"]!=0 ) && \
	   column["PR"]!=0){
	   calcdens=1;
	   if ( column["PT"]==0 ) {
	     calcthet=1;
	     print "# " TimeStr ": sw_ptmp: Calculate potential temperature"
	     cols++;
	     param[cols]="PT";
	     column[param[cols]]=cols;
	     $0=$0 "\tPT"
	     } else {calcthet=0};
	   print "# " TimeStr ": sw_dens: Calculate sigma-theta"
	   cols++;
	   param[cols]="S0";
	   column[param[cols]]=cols;
	   $0=$0 "\tS0"
	   } else {calcdens=0}

	print "@" toupper($0)
	getline
}
data{  
	if (calcthet){
	  $column["PT"]=$column["SA"]<=-9||$column["SA"]<=-9||$column["SA"]<=-9?-9999:sw_ptmp($column["SA"],$column["TE"],$column["PR"],0);
	  }
	if (calcdens){ 
	  $column["S0"]=$column["SA"]<=-9||$column["PT"]<=-9?-9999:sw_dens($column["SA"],$column["PT"],0)-1000;
	  }
	for (i=1;i<cols;i++){printf "%g\t",$column[toupper(param[i])]};
	printf "%g\n",$column[toupper(param[i])];
	}
	

