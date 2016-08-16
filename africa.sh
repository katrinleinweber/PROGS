#! /bin/bash

if hash gmt 2> /dev/null ; then
	echo Running version 5 of GMT
	GMTWRAP=gmt
fi

if hash GMT 2> /dev/null ; then
	echo Running version 4 of GMT
	GMTWRAP=""
fi

$GMTWRAP pscoast

