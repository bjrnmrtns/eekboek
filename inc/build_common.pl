# build_common.inc -- Build file common info -*- perl -*-
# RCS Info        : $Id: build_common.pl,v 1.4 2005/11/30 12:11:25 jv Exp $
# Author          : Johan Vromans
# Created On      : Thu Sep  1 17:28:26 2005
# Last Modified By: Johan Vromans
# Last Modified On: Wed Nov 30 13:11:19 2005
# Update Count    : 23
# Status          : Unknown, Use with caution!

use strict;
use Config;
use File::Spec;

our $data;

$data->{author} = 'Johan Vromans (jvromans@squirrel.nl)';
$data->{abstract} = 'Elementary Bookkeeping (for the Dutch/European market)';
$data->{pl_files} = {};
$data->{installtype} = 'site';
$data->{distname} = 'EekBoek';
$data->{name} = "eekboek";
$data->{script} = [ map { File::Spec->catfile("script", $_) }
		     qw(ebshell) ];
$data->{prereq_pm} = {
		      'Getopt::Long' => '2.13',
		      'Term::ReadLine' => 0,
		      'Term::ReadLine::Gnu' => 0,
		      'DBI' => 1.40,
		      'DBD::Pg' => 1.41,
#		      'Text::CSV_XS' => 0,
#		      'Locale::gettext' => 1.05,
	       };
$data->{recomm_pm} = {
		'Getopt::Long' => '2.32',
	       };
$data->{usrbin} = "/usr/bin";

sub checkbin {
    my ($msg) = @_;
    my $installscript = $Config{installscript};

    return if $installscript eq $data->{usrbin};
    print STDERR <<EOD;

WARNING: This build process will install a user accessible script.
The default location for user accessible scripts is
$installscript.
EOD
    print STDERR ($msg);
}

use File::Find;

sub filelist {
    my ($dir, $pfx) = @_;
    $pfx ||= "";
    my $dirl = length($dir);
    my $pm;
    find(sub {
	     if ( $_ eq "CVS" ) {
		 $File::Find::prune = 1;
		 return;
	     }
	     return if /^#.*#/;
	     return if /~$/;
	     return unless -f $_;
	     if ( $pfx ) {
		 $pm->{$File::Find::name} = $pfx .
		   substr($File::Find::name, $dirl);
	     }
	     else {
		 $pm->{$File::Find::name} = $pfx . $File::Find::name;
	     }
	 }, $dir);
    $pm;
}

sub WriteSpecfile {
    my $name    = shift;
    my $version = shift;

    my $fh;
    if ( open ($fh, "$name.spec.in") ) {
	print "Writing RPM spec file...\n";
	my $newfh;
	open ($newfh, ">$name.spec");
	while ( <$fh> ) {
	    s/%define modname \w+/%define modname $name/;
	    s/%define modversion \d+\.\d+/%define modversion $version/;
	    print $newfh $_;
	}
	close($newfh);
    }
}

sub vcopy($$) {
    warn("WARNING: vcopy is untested!\n");
    my ($file, $vars) = @_;

    my $pat = "(";
    foreach ( keys(%$vars) ) {
	$pat .= quotemeta($_) . "|";
    }
    chop($pat);
    $pat .= ")";

    $pat = qr/\b$pat\b/;

    warn("=> $pat\n");

    my $fin = $file . ".in";
    open(my $fi, "<$fin") or die("Cannot open $fin: $!\n");
    open(my $fo, ">$file") or die("Cannot create $file: $!\n");
    while ( <$fi> ) {
	s/$pat/$vars->{$1}/ge;
	print;
    }
    close($fo);
    close($fi);
}

1;
