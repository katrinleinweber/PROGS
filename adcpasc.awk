#
# This is a gawk script
# ADCPASC - 	Parses ADCP ascii files
# Usage - 	gawk -f adcpasc.awk <Files>
#		Use the matlab script adcpview.m to display the output from 
#		this script
#

BEGIN{Count=0; OFS="\t";}
{ Count++ }
# Process entire ensemble as a "record" using getlines
!/^[ \t\f\n\r\v]*$/{
# first line is the ensemble time. Year is not specified, assume 2000
# Fields are
# (month)(day)(hour:minute:second)(Ensemble number)(Number of ensembles in segment)(Pitch)(Roll)(Corrected heading)(ADCP temperature)

  Mon=$1;Day=$2;Tim=$3;EnsNo=$4;NumEns=$5;Pitch=$6;Roll=$7;Head=$8;Temp=$9;
# Get the date as a Unix timestamp
  pipecmd="date -d \"2000-" Mon "-" Day " " Tim "\" +%s ";
  pipecmd | getline Date ; close(pipecmd);
#
# Get the second line; is the bottom track info and the beam depths
  getline;
    BTEast=$1;BTNorth=$2;BTVert=$3;BTErr=$4;
    BDepth[1]=$5;BDepth[2]=$6;BDepth[3]=$7;BDepth[4]=$8;
#
# Get the third line; is the elapsed time and the course made good
  getline;
    ElDist=$1; ElTime=$2; CMG=$3;
# 
# Get the fourth line; Navigation data
  getline;
    Lati=$1; Long=$2; NavEast=$3; NavNorth=$4; DistTrav=$5;
#
# Get the Fifth line; discharge values
  getline;

# Get the sixth line; unit info
  getline;
    NLevels=$1; Measure=$2; Ref=$3;
#
# get NLevels of  bin data
  for (n=1; n<=NLevels; n++){
    getline;
      Bin=$1; Mag=$2; Dir=$3; EVel=$4; NVel=$5; VVel=$6; Err=$7;
      Int[1]=$8; Int[2]=$9; Int[3]=$10; Int[4]=$11; Percent=$12;
      Discharge=$13;
    # if (Percent>5){print Lati,Long,Mag,Dir,Bin,Date,Head};
	# if (EVel!=32767 || NVel!=32767){print Date,BTEast,BTNorth,Head,NavEast,NavNorth,Lati,Long,n,Bin-8,Bin,EVel,NVel,Mag,Dir,VVel,Err,Int[1]+Int[2]+Int[3]+Int[4],Percent};
	if (EVel!=32767 || NVel!=32767){print Date,BTEast,BTNorth,Head,NavEast,NavNorth,Lati,Long,n,Bin-8,Bin,EVel,NVel,Mag,Dir,VVel,Err,Int[1]+Int[2]+Int[3]+Int[4],Percent};
    }
}

