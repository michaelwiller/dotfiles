#!/usr/bin/perl

use strict;
use Getopt::Std;
use File::Spec;
use File::Basename;

my $FAV_RESULT='.';

my $FAV_DIR = "$ENV{HOME}/.config/references";
my $FAV_FILE;
my %FAVORITES;
my $topic;

if ( @ARGV == 0) {
	HELP_MESSAGE();
	exit 0;

} else {

	my $arg = $ARGV[0];
	if ( ! -d $FAV_DIR ) {
		mkdir $FAV_DIR;
	}

	if ( $arg eq "-x" ) {
		opendir(DIR,$FAV_DIR);
		my @files = readdir(DIR);
		foreach my $f (@files) {
			unless ( ($f eq ".") || ($f eq "..") ) { printf("%s ",$f); }
		}
		exit 0;
	} 

	my $s = substr($arg, 0,1);

	if ( $s eq "-" ) {
		printf( STDERR "Unknown option %s\n",$arg);
		HELP_MESSAGE();
		exit 2;
	}

	#	$FAV_DIR = "$ENV{HOME}/.fav";
	if ( @ARGV == 1 ) {
		$topic = "favorites"
	} else {
		$topic=$arg;
		shift;
	}
	$FAV_FILE = "$FAV_DIR/$topic";
	if (! -e $FAV_FILE){
	    &saveFavorites;
	}
	#printf(STDERR "File: $FAV_FILE \n");
}

sub main::VERSION_MESSAGE() {
	print "The is fav, v.1.0.0 for Mac OS X \n";
	print "Copyright Michael Willer\n";
}
sub main::HELP_MESSAGE(){
  printf(STDERR "\nUsage: %s [[-t] | TOPIC [ -a NAME | -d NAME | -l | -e ]\n", basename $0);
	printf(STDERR "   -x     : list topics\n");
	printf(STDERR "   NAME   : Get reference key NAME in TOPIC\n");
	printf(STDERR "   -a NAME: Add reference with NAME as key in TOPIC\n");
	printf(STDERR "   -d NAME: Delete reference with NAME as key in TOPIC\n");
	printf(STDERR "   -e     : Edit the references in TOPIC\n");
	printf(STDERR "   -l     : List all references in TOPIC\n");
}

sub readFavorites(){
	if ( ! -f $FAV_FILE ) {
		&saveFavorites;  # Save empty file
	}

	open FAVS, "<", $FAV_FILE;

	foreach (<FAVS>) {
		chomp;
		my ($fav,$favdir) = (split(/:/ ) )[1,2];
		$FAVORITES{$fav} = $favdir;
	}

	close FAVS;
}

sub saveFavorites(){
	open(FAVS, ">", "$FAV_FILE") or die "Can't open $FAV_FILE: $!";
	printf FAVS ":%s:%s\n" , $_, $FAVORITES{$_}		foreach sort keys %FAVORITES;
	#printf STDERR "Saving :%s:%s\n" , $_, $FAVORITES{$_}		foreach sort keys %FAVORITES;
	close FAVS;
}

sub printFavorites {
	printf STDERR "%-25s %s\n", $_, $FAVORITES{$_}     foreach sort keys %FAVORITES;
}



$Getopt::Std::STANDARD_HELP_VERSION=1;

my %options;
getopts('xa:d:el', \%options);

# Process options that do not require reading of file

if ( $options{e} ) {
	print "EDIT#" . "$FAV_FILE";
	exit;
}
#
# Read current references
#
&readFavorites;

#
# Process options after reading references
#
my $favsUpdated;

if ( $options{x} ) {
	print "$_ " foreach keys %FAVORITES;
	exit 0;
}
if ( $options{a} ) {
	if ( !( @FAVORITES{ $options{a} } eq @ENV{ PWD } )){
		$FAVORITES{ $options{a} } = $ENV { PWD };
		$favsUpdated=1;
		&saveFavorites;
	}
}
if ( $options{d} ) {
	delete $FAVORITES{ $options{d} } ;
	$favsUpdated=1;
	&saveFavorites;
}
if ( $favsUpdated || $options{l} ) {
	&printFavorites;
}

#
# Process parameters (if any)
#
my $count = @ARGV;

if ( $count ) {
	my $f = shift @ARGV;
	my $t = $FAVORITES{ $f };
	
	if ( $t ){
		print $t;
		exit;
	} else {
		print STDERR "No reference found: $topic:$f\n";
	}
}
