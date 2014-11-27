#!/usr/local/bin/perl
#
# vacation program
# Larry Wall <lwall@jpl-devvax.jpl.nasa.gov>
#
# updates by Tom Christiansen <tchrist@convex.com>,
#            Rex Pruess <Rex-Pruess@uiowa.edu> (May 1992).
#
# The vacation options are described below (as documented in the man page).
#
#  -aalias   Indicate that alias is one of the valid aliases for your login
#            name.  Mail addressed to the alias generates a vacation reply.
#            Use -a repetitively to specify multiple aliases.  An example
#            is "-aSantaClaus -aSanta" for the login name of sclaus.  Mail
#            addressed to SantaClaus, Santa, or sclaus results in a vaca-
#            tion reply.  The case of letters is ignored in making com-
#            parisons.
#
#  -ffile    Do not send vacation replies to the user names listed in file.
#            User names are white-space separated.
#
#  -j        Do not check whether the recipient appears in the To: or the
#            Cc: line.  In other words, send replies to users even if the
#            mail is not directly addressed to your login name or an alias
#            for it.
#
#  -I        Initialize the .forward, .vacation.msg, .vacation.dir, and
#            .vacation.pag files.
#
#  -l        List the contents of the .vacation.dir and .vacation.pag
#            files.  This lists the users who received your vacation
#            notice.
#
#  -tN       Change the interval between repeat replies to the same sender.
#            The default is "1w" (one week).  A trailing s, m, h, d, or w
#            scales N to seconds, minutes, hours, days, or weeks, respec-
#            tively.

$vacation = $0;
$vacation = '/usr/local/bin/nvacation' unless $vacation =~ m#^/#;

$user = $ENV{'USER'} || $ENV{'LOGNAME'} || getlogin || (getpwuid($>))[0];
$editor = $ENV{'VISUAL'} || $ENV{'EDITOR'} || 'vi';
$pager = $ENV{'PAGER'} || 'more';

$default_msg = <<'EOF';
I will not be reading my mail for a while.
Your mail regarding "$SUBJECT" will be read when I return.
EOF


if (!@ARGV) {		# interactive use, a la Sun
    &interactive();
    die "not reached";
}

@ignores = ( 
	'daemon',
	'postmaster',
	'mailer-daemon',
	'mailer',
	'operator',
	'root',
     );

# set-up time scale suffix ratios
%scale = (
	's', 1,
	'm', 60,
	'h', 60 * 60,
	'd', 24 * 60 * 60,
	'w', 7 * 24 * 60 * 60,
    );


while ($ARGV[0] =~ /^-/) {
    $_ = shift;
    if (/^-I/i) {  # eric allman's source has both cases
	chdir;

	&initialize;

        if ( !(-f '.vacation.msg') || &yorn ("Do you wish to replace your \".vacation.msg\" file?") ) {
           &make_default;
        }

	exit;
    } elsif (/^-l/) {
        &list_aliases ();
        exit;
    } elsif (/^-j/) {
	push (@forOpts, '-j');
	$opt_j++;
    } elsif (/^-f(.*)/) {
	&save_file($1 ? $1 : shift);
    } elsif (/^-a(.*)/) {
	&save_alias($1 ? $1 : shift);
    } elsif (/^-t([\d.]*)([smhdw])/) {
	push (@forOpts, $_);
	$timeout = $1;
	$timeout *= $scale{$2} if $2;
    } else {
	die "Unrecognized switch: $_\n";
    }
}

if (!@ARGV) {
    &interactive();
    die "not reached";
}


$user = shift;
push(@ignores, $user);
push(@aliases, $user);
die "Usage: vacation username\n" if $user eq '' || @ARGV;

$home = (getpwnam($user))[7];
die "No home directory for user $user\n" unless $home;
chdir $home || die "Can't chdir to $home: $!\n";

$timeout = 7 * 24 * 60 * 60 unless $timeout;

dbmopen(VAC, ".vacation", 0666) || die "Can't open vacation dbm files: $!\n";


$/ = '';			# paragraph mode
$header = <>;
$header =~ s/\n\s+/ /g;		# fix continuation lines
$* = 1;

exit if $header =~ /^Precedence:\s*(bulk|junk)/i;
exit if $header =~ /^From.*-REQUEST@/i;

for (@ignores) {
    exit if $header =~ /^From.*\b$_\b/i;
} 

($from) = ($header =~ /^From\s+(\S+)/);	# that's the Unix-style From line
die "No \"From\" line!!!!\n" if $from eq "";

($subject) = ($header =~ /Subject:\s+(.*)/);
$subject = "(No subject)" unless $subject;
$subject =~ s/\s+$//;

($to) = ($header =~ /To:\s+(.*)/);
($cc) = ($header =~ /Cc:(\s+.*)/);
$to .= ', '.$cc if $cc;

if (open(MSG,'.vacation.msg')) {
    undef $/;
    $msg = <MSG>;
    close MSG;
} else {
    $msg = $default_msg;
} 
$msg =~ s/\$SUBJECT/$subject/g;		# Sun's vacation does this

unless ($opt_j) {
    foreach $name (@aliases) {
	$ok++ if $to =~ /\b$name\b/i;
    }
    exit unless $ok;
}

$lastdate = $VAC{$from};
$now = time;
if ($lastdate ne '') {
    ($lastdate) = unpack("L",$lastdate);
    exit unless $lastdate;
    exit if $now < $lastdate + $timeout;
}

$VAC{$from} = pack("L", $now);
dbmclose(VAC);


open(MAIL, "|/usr/lib/sendmail -oi -t $from") || die "Can't run sendmail: $!\n";

print MAIL <<EOF;
To: $from
Subject: This is a recording... [Re: $subject]
Precedence: junk

EOF
print MAIL $msg;
close MAIL;
exit;

sub yorn {
    local($answer);
    for (;;) {
	print $_[0];
	$answer = <STDIN>;
	last if $answer =~ /^[yn]/i;
	print "Please answer \"yes\" or \"no\" ('y' or 'n')\n";
    }
    $answer =~ /^y/i;
}

sub interactive {
    chdir;
    chop($cwd = `pwd`);

    &disable if -f '.forward';

    print <<EOF;
This program can be used to answer your mail automatically
when you go away on vacation.
EOF

    for (;;) {
	if (-f '.vacation.msg') {
	    print "\nYou already have a message file in \"$cwd/.vacation.msg\".\n";
	    $see = &yorn("Would you like to see it? ");
	    system $pager, '.vacation.msg' if $see;
	    $edit = &yorn("Would you like to edit it? ");
	}
	else {
	    &make_default;
	    print <<EOF;

I've created a default vacation message in \"~/.vacation.msg\".  This
message will be automatically returned to anyone sending you mail while
you're out.

Press return when ready to continue, and you will enter your favorite
editor ($editor) to edit the messasge to your own tastes.  

EOF
	    $| = 1;
	    print "Press return to continue: "; 
	    <STDIN>;
	    $edit = 1;
	}

	last unless $edit;
	system $editor, '.vacation.msg';
	last;
    }


    print "\nTo enable the vacation feature a \".forward\" file is created.\n";
    if (&yorn("Would you like to enable the vacation feature now? ")) {
	&initialize;
	print <<EOF;

Ok, vacation feature ENABLED.  Please remember to turn it off when
you get back from vacation.  Bon voyage!
EOF
    }
    else {
	    print "Ok, vacation feature NOT enabled.\n";
	}

    exit;
}

sub initialize {
    local($opt);

    &zero('.vacation.pag');
    &zero('.vacation.dir');

    if ( !(-f '.forward') || &yorn ("Do you wish to replace your \".forward\" file?") ) {
       open(FOR, ">.forward") || die "Can't create .forward: $!\n";
       print FOR "\\$user, \"|$vacation ";

       if (defined (@forOpts)) {
          foreach $opt (@forOpts) {
             print FOR "$opt ";
          }
       }

       printf FOR "$user\"\n";
       close FOR;
    }

} 

sub zero {
    local($FILE) = @_;
    open (FILE, ">$FILE") || die "can't creat $FILE: $!";
    close FILE;
} 

sub save_alias {
   push (@forOpts, '-a', @_);
   push(@aliases, @_);
}

sub save_file {
    push (@forOpts, '-f', @_);
    local($FILE) = @_;
    local($_);

    open (FILE) || die "can't open $FILE: $!";

    while (<FILE>) {
	push(@ignores, split);
    } 
    close FILE;
} 

sub disable {
    print "\nYou have a \".forward\" file in your home directory containing: ",
	  "\n",
	  `cat .forward`,
	  "\n";
    if (&yorn(
"Would you like to remove it and disable the vacation feature? ")) {
	unlink('.forward') || die "Can't unlink .forward: $!\n";
        &list_aliases ();
	print "Back to normal reception of mail.\n";
	exit;
    } else {
	print "Ok, vacation feature NOT disabled.\n";
    }
} 

sub make_default {
    open(MSG, ">.vacation.msg") || die "Can't create .vacation.msg: $!\n";
    print MSG $default_msg;
    close MSG;
} 

sub list_aliases {
    local($key, @keys, $when);    

    dbmopen(VAC, '.vacation', 0444) || die "no .vacation dbmfile\n";

    sub byvalue { $VAC{$a} <=> $VAC{$b}; }

    if (@keys = sort byvalue keys %VAC) {
       require 'ctime.pl';
       open (PAGER, "|$pager") || die "can't open $pager: $!";
       print PAGER <<EOF;
While you were away, mail was sent to the following addresses:

EOF
       for $key (@keys) {
   	   ($when) = unpack("L", $VAC{$key});
           printf PAGER "%-20s %s", $key, &ctime($when);
       } 

       close PAGER;
    }
}

