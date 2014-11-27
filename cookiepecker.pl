#!/usr/bin/perl -w
#
# Copyright 1998 by John Carter <ece at dwaf-hri dot pwv dot gov dot za>
#
$help = "Randomizes, slightly your cookies in an intelligent fashion.";
# 
# 

if( $#ARGV == 0 && $ARGV[0] eq "-h")
{
  print  STDERR "$help\n";
  exit 1;
}

$home = $ENV{"HOME"};

rename( "$home/.netscape/cookies", "$home/.netscape/cookies.bkp") || die "Couldn't rename cookies";
open( INF, "$home/.netscape/cookies.bkp") || die "Couldn't find cookie file.";
open( OUTF, ">$home/.netscape/cookies") || die "Couldn't create new cookies.";
LINE : while(<INF>)
{
  chomp;
  @line = split/\t/;
  if( $#line < 6)
  {
    print OUTF "$_\n";
    next LINE;
  }
  ($url, $bool1, $path, $bool2, $expire, $name, $value) = @line;

  if( $name !~ /userid/i && $name !~ /passwd/i)
  { # Corrupt a random character.
    $charNum = int( rand( length( $value)));
    print "Changing $value to ";
    substr( $value, $charNum, 1) = chr( ord( "A") + int(rand(26)));
    print "$value\n";
  }
  print OUTF "$url\t$bool1\t$path\t$bool2\t$expire\t$name\t$value\n";
}
close( INF);
close( OUTF);
