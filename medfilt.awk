BEGIN{	i=0;
	N=3
	}
{	x=$1 
	for (i=2;i<=N;i++) { a[i]=a[i-1] }; 
	a[1]=x;
	y=median(a); 
	print x,y
	}

function median(a,N,	i,b)
{	for (i=1; i<=N; i++){ 
		if ( a[i] < a[i+1] ) {
			b=a[i];a[i]=a[i+1]; a[i+1]=b;
			} 
		}
	for (i=1; i<=N; i++){ print a[i] }
return a[2]}

