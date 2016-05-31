#!/bin/gawk -f
BEGIN{
	print "==============================================================================\n                           DDS Validation Log\n==============================================================================\n"
	DS=0.15;
	DTE=0.6;
	LA=0.01;
	LO=0.01;
	}
{	da1=$1; ti1=$2; 
	t1=$3;
	a1=$4;
	n1=$5;
	s1=$6;
	te1=$7;
	dt=t1-t0;
	da=a1-a0;
	dn=n1-n0;
	ds=s1-s0;
	dte=te1-te0;
	}
NR==1{	first_date=da1 " " ti1 }
NR!=1 && ( dt>60 || dt<0 ){
	printf \
"Time gap:      Time jumps from %s %s to %s %s\n",da0,ti0,da1,ti1;
	print "-"
	}
NR!=1 && abs(da)>LA {
	printf \
"Latitude step:    %7.3f from %s %s to %s %s\n",da,da0,ti0,da1,ti1;
	# print "-"
	}
NR!=1 && abs(dn)>LO {
	printf \
"Longitude step:    %7.3f from %s %s to %s %s\n",dn,da0,ti0,da1,ti1;
	# print "-"
	}
NR!=1 && abs(ds)>DS {
	printf \
"Salinity step:    %7.3f from %s %s to %s %s\n",ds,da0,ti0,da1,ti1;
	# print "-"
	}
NR!=1 && abs(dte)>DTE {
	printf \
"Temperature step: %7.3f from %s %s to %s %s\n",dte,da0,ti0,da1,ti1;
	# print "-"
	}
{	da0=da1; ti0=ti1; t0=t1; a0=a1; n0=n1; s0=s1; te0=te1; n0=n1; orec=$0
	mint 
	maxt
	minlat
	maxlat
	minlon
	maxlon
	
	}
END{ print "==============================================================================\n" NR " records processed"
	print "From " first_date " to " da1 " " ti1
	}


