# Applies salinity and oxygen calibrations to s87 files
# Also applies conductivity calibration. DOES NOT RECOMPUTE SALINITY.
# USE s87salt TO RECALCULATE SALINITY AFTER CONDUCTIVITY CORRECTION
BEGIN{
# initialize a marker
	data=0
# Set up some defaults
	OFS="\t"
	if (OSL==0){OSL=1}
	if (OIN==0){OIN=0}
	if (SSL==0){SSL=1}
	if (SIN==0){SIN=0}
	if (CSL==0){CSL=1}
	if (CIN==0){CIN=0}
	TimeStr=strftime("%Y-%m-%d %H:%M");
	}

# NR==1{	print }
# /^&/{	print }
# /^#/{	print }
data==0&&!/^@/{print}
/^@/{   data=1;
	if (OSL!=1 || OIN!=0){
		if (OIN<0){
		  print "# " TimeStr ": Oxygen Calibration OX=OX*" OSL OIN
		  } else {
		  print "# " TimeStr ": Oxygen Calibration OX=OX*" OSL "+" OIN
		  }
		}
	if (SSL!=1 || SIN!=0){
		if (SIN<0){
		  print "# " TimeStr ": Salinity Calibration SA=SA*" SSL SIN
		  } else {
		  print "# " TimeStr ": Salinity Calibration SA=SA*" SSL "+" SIN
		  }
		}
	if (CSL!=1 || CIN!=0){
		if (CIN<0){
		  print "# " TimeStr ": Conductivity Calibration CO=CO*" CSL CIN
		  } else {
		  print "# " TimeStr ": Conductivity Calibration CO=CO*" CSL "+" CIN
		  }
		}
	if (COMMENT!=0){
		print "# " COMMENT
		}
#	print "@PR\tTE\tSA\tOX"
	sub("^@","");
	cols=split($0,param);
	for (i=1;i<=cols;i++){column[toupper(param[i])]=i};
	print "@" toupper($0)
	getline
}
data{  
	if (CSL!=1 || CIN!=0){
		if ($column["CO"]>-9){$column["CO"]=$column["CO"]*CSL+CIN}
		}
	if (SSL!=1 || SIN!=0){
		if ($column["SA"]>-9){$column["SA"]=$column["SA"]*SSL+SIN}
		}
	if (OSL!=1 || OIN!=0){
		if ($column["OX"]>-9){$column["OX"]=$column["OX"]*OSL+OIN}
		}
#	print $column["PR"],$column["TE"],$column["SA"],$column["OX"]
	for (i=1;i<cols;i++){printf "%g\t",$column[toupper(param[i])]};
	printf "%g\n",$column[toupper(param[i])];
	}
	

