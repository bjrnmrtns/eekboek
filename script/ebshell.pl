#! perl

# ebshell -- Main script for EekBoek CLI shell
# Author          : Johan Vromans
# Created On      : Thu Jul 14 12:54:08 2005
# Last Modified By: Johan Vromans
# Last Modified On: Fri Sep  1 11:01:32 2017
# Update Count    : 124
# Status          : Unknown, Use with caution!

package main;

use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;

use Encode;
binmode( STDERR, ':encoding(utf-8)' );

use FindBin;
our $bin = $FindBin::Bin;

# Common case when run from unpacked dist.
my $lib = File::Spec->catfile( dirname($bin), "lib" );
if ( -s File::Spec->catfile( $lib, "EekBoek.pm" ) ) {
    # Need abs paths since we're going to chdir later.
    unshift( @INC, File::Spec->rel2abs($lib) );
    my $sep = $ENV{PATH} =~ m?;??q:;::q;:;;;; # just for fun
    $ENV{PATH} = File::Spec->rel2abs($lib) . $sep . $ENV{PATH};
}

# use App::Packager;

check_install( "EekBoek", "EekBoek.pm", "EB.pm", "EB/res/schema/eekboek.sql" );

require EekBoek;
check_version( "EekBoek", $EekBoek::VERSION, "2.030" );

require EB::Main;
exit EB::Main->run;

################ Subroutines ################

sub findfile {
    my ( $file ) = @_;
    return if $App::Packager::PACKAGED;

    foreach ( @INC ) {
	my $f = File::Spec->catfile( $_, $file );
	return $f if -s $f;
    }
    return;
}

sub check_install {
    # Trust packager.
    return 1 if $App::Packager::PACKAGED;

    my ( $what, @checks ) = @_;
    foreach ( @checks ) {
	next if findfile( $_ );
	error( <<END_MSG, "Installatiefout" );
$what is niet geïnstalleerd, of kon niet worden gevonden.

Raadplaag uw systeembeheerder.
END_MSG
	return;
    }
}

sub check_version {
    my ( $what, $version, $required ) = @_;
    $version =~ s/^(\d+\.\d+\.\d+).*/$1/;
    return if $version ge $required;
    error( <<END_MSG, "Ontoereikende $what versie" );
De geïnstalleerde versie van $what is niet toereikend.
Versie $version is geïnstalleerd terwijl versie $required of later is vereist.

Raadplaag uw systeembeheerder.
END_MSG
}

################ Messengers ################

sub error {
    my ( $msg, $caption, $style ) = @_;
    warn( $caption, "\n", $msg, "\n" );
    exit(1);
}

1;

=head1 NAME

EekBoek - Bookkeeping software for small and medium-size businesses

=head1 SYNOPSIS

  ebshell

EekBoek is a bookkeeping package for small and medium-size businesses.
Unlike other accounting software, EekBoek has both a command-line
interface (CLI) and a graphical user-interface (GUI). Furthermore, it
has a complete Perl API to create your own custom applications.

EekBoek is designed for the Dutch/European market and currently
available in Dutch only. An English translation is in the works (help
appreciated).

=head1 DESCRIPTION

For a description how to use the program, see L<http://www.eekboek.nl/docs/index.html>.

=head1 BUGS AND PROBLEMS

Please use the eekboek-users mailing list at SourceForge.

=head1 AUTHOR AND CREDITS

Johan Vromans (jvromans@squirrel.nl) wrote this package.

Web site: L<http://www.eekboek.nl>.

=head1 COPYRIGHT AND DISCLAIMER

This program is Copyright 2005-2010 by Squirrel Consultancy. All
rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of either: a) the GNU General Public License as
published by the Free Software Foundation; either version 1, or (at
your option) any later version, or b) the "Artistic License" which
comes with Perl.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See either the
GNU General Public License or the Artistic License for more details.

=cut
