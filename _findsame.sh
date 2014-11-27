#! /bin/bash 

find $@ \( -type d \( -name trash -o -name .xvpics \) -o \
	  -type f \( -name MD5SUM -o -name SHASUM -o -name MD5SHASUM \) \) \
	-prune -o	\
	-type f -print0 | 
	tee >(  xargs -0 md5sum > MD5SUM ) 	\
	>( xargs -0 shasum > SHASUM ) > /dev/null 

while ps ax | grep -v grep | grep "md5sum\|shasum" > /dev/null ; do 
	sleep 1
done

awk 'BEGIN{
	while(getline md5 < "MD5SUM"){
		getline sha < "SHASUM"
		split(md5,M)
		split(sha,S)
		if(M[2]!=S[2]){
			print "Wrong files!",S[2], M[2] > "/dev/stderr"
			exit 1
			}
		print M[1] sha 
		}
	}' | tee MD5SHASUM | sort | uniq -D -w 72


#
# vim:se nowrap tw=0 : 
# 
