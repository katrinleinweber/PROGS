#!/usr/local/bin/perl -w
#
# Will convert an addressbook in pine format to a KMail addressbook.
# (c) Lakshman, NSSL, 2001   lakshman at nssl noaa gov
# Provided AS IS, with no warranty whatsoever
# May be freely distributed as long as this copyright remains intact.
#
$home = $ENV{"HOME"};
$pineaddr  = "$home/.addressbook";
$kmailaddr = "$home/.kde/share/apps/kmail/addressbook";

if ( $#ARGV > 0 ) {

  if ( $#ARGV != 1 ) { 
    usage(); 
  }
  $pineaddr = $ARGV[0];
  $kmailaddr = $ARGV[1];

}

open IN, "< $pineaddr" or die "Unable to open $pineaddr for reading.\n";
open OUT, ">> $kmailaddr" or die "Unable to open $kmailaddr for writing.\n";

print "Changing addresses in $pineaddr and appending to $kmailaddr\n";

$curr_entry = ""; # not found yet

while (<IN>){
  # split the input line
  chop;
  $this_line = $_;
  if ( $this_line =~ /^ / ){
    # starts with a white space. Simply append this line to previous
    $curr_entry = "$curr_entry $this_line";
  }
  else {
    # time to do the previous entry since we are starting a new one
    process_entry( $curr_entry );
    $curr_entry = $this_line;
  }
}

sub process_entry() {
  ($_) = @_;
  @args = split;
  if ( $#args < 0 ){
    return;
  }
  
  # the first word is the alias
  $alias = $args[0]; # first word is the alias.
  $email = "";
  for ( $i = 0; $i <= $#args; $i++ ){
    if ( $args[ $i ] =~ /@/ ){
      $email = "$email $args[$i]";
    }
  }
  if ( $email !~ /@/ ){
    print "Skipping `$_` -- don't know what to do with it.\n";
    return;
  }

  # the last word is the email address.
  $email =~ s/ //g; # no extra spaces
  $email =~ s/<//g; # no <
  $email =~ s/>//g; # no >
  $email =~ s/\(//g; # no (
  $email =~ s/\)//g; # no )

  # print OUT "# $_ \n";
  print OUT "$alias <$email> \n";
}

sub usage(){
  print "Usage: pineToKmail.pl [pine-addressbook kmail-addressbook] \n";
  print "   will incorporate all the addresses in the pine adressbook\n";
  print "   and APPEND them to the kmail addressbook. \n";
  print "   If the two adressbooks are not provided, then the following\n";
  print "   default locations are used: \n";
  print "               $pineaddr  for pine \n";
  print "               $kmailaddr for KDE  \n";
  print "(c) Lakshman, NSSL, 2001 \n";
  exit(0);
}
