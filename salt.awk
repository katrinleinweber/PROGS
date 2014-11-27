BEGIN{	OFS="\t"
	T=-9999;
	print "Sample\t2xCondR\tSalinity"
	}
{if (T<-99){
	print "Bath temperature not supplied, using 21C"; T=21}
	}
{print $1,$2,sw_sals($2/2,T)}
END{print ""}
