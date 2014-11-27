BEGIN { hl=0; 
	min=-10.5 ; 
	del=0.25;
	newdel=1;
	range=4.5;
	max=min+del;
	R=1;
	ArrNum=0;
	}

{sub("$",""); while (sub(" $",""));}

NR==1 {
	split(FILENAME,fn,".")
	hfn=fn[1] ".HDR"
#	if (system("test -f " hfn)!=0) {hfn=toupper(hfn)}
	if (system("test -f " hfn)!=0) {print "File " hfn " does not exist" > "/dev/stderr"; exit}; 
	rfn=fn[1] ".PR2"
	print "Processing " FILENAME "\n\tAdding header from " hfn "\n\tWriting to " rfn

	while (getline < hfn) {
		sub("$",""); while (sub(" $",""));
		if (!/^$/) {
			print		 				> rfn
			}
		}
	close(hfn)
	while (hl<3) {
		getline;
		sub("$",""); while (sub(" $",""));
		if (/^===/){ hl++ }
		if (/^SCAN/){
			headstr=$0;
			print headstr,"    NOBS\n"		> rfn
# try to find the min and max of data
#		fields=NF;
			for (i=1;i<=NF;i++){
				arr[i]=0;
#			oarr[i]=0
#			maxarr[i]=-1e38
#			minarr[i]=1e38
#			maxdarr[i]=-1e38
#			mindarr[i]=1e38
				}
			n=0;
			}
		}
	}
# hl>=3 {
min<$2 && $2<=max { 
		for (i=2;i<=NF;i++) { arr[i]+=$i }
		n++
		}
$2>max {
		if (R==1 && min>=range) { del=newdel; max=min+del; R=0}
		while ($2>max) { max+=del; min+=del }
		if (n>=1) {
			for (i=2;i<=NF;i++) { arr[i]=arr[i]/n }
			printf "%6d, ",arr[1] 			> rfn
			printf "%6.1f, ",arr[2]			> rfn
			for (i=3;i<=NF;i++) {
				printf "%6.3f, ",arr[i] 	> rfn
				}
			printf "%d\n",n				> rfn

# try to find the min and max of data
#			for (i in arr){
#				darr[i]=arr[i]-oarr[i];
#				if (darr[i]>maxdarr[i]){maxdarr[i]=darr[i]}
#				if (darr[i]<mindarr[i]){mindarr[i]=darr[i]}
#				if (arr[i]>maxarr[i]){maxarr[i]=arr[i]}
#				if (arr[i]<minarr[i]){minarr[i]=arr[i]}
#				oarr[i]=arr[i]
#				};
			}
		for (i=1;i<=NF;i++) { arr[i]=$i };
		n=1;
		}

END{
	if (n>=1) {
		for (i in arr){ArrNum++; if (i!=1){ arr[i]=arr[i]/n }}
		printf "%6d, ",arr[1] 			> rfn
		printf "%6.1f, ",arr[2]			> rfn
		for (i=3;i<=ArrNum;i++) {
			printf "%6.3f, ",arr[i] 	> rfn
			}
		printf "%d\n",n				> rfn
		}
	close(rfn)

#	print  "          " headstr
#	printf "Max Data  "; printdata(maxarr)
#	printf "Min Data  "; printdata(minarr)
#	printf "Max Diff  "; printdata(maxdarr)
#	printf "Min Diff  "; printdata(mindarr)
	}

#function printdata(array){
#	printf "%6d  ",array[1]
#	printf "%6.1f  ",array[2]
#	for (i=3;i<=fields;i++) {
#		printf "%6.3f  ",array[i]
#		}
#	printf "\n"
#	}
#
