BEGIN{	FIELDWIDTHS="6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6";
	delta=5;
	x=0*60;
	y=90*60;
	}
{	for (i=1;i<=NF;i++){ 
		printf "%g\t%g\t%d\n",x/60,y/60,$i
		x+=delta; 
		if (x>=(360*60)){x=0;y-=delta}
		} 
	}
END{
	for (x=0;x<360*60;x+=delta){
		printf "%g\t%g\t%d\n",x/60,y/60,2810
		}
	}
