# RCS Info        : $Id: Html.pm,v 1.1 2005/11/19 22:05:47 jv Exp $
# Author          : Johan Vromans
# Created On      : Sat Oct  8 16:40:43 2005
# Last Modified By: Johan Vromans
# Last Modified On: Sat Nov 19 23:00:54 2005
# Update Count    : 37
# Status          : Unknown, Use with caution!

package main;

our $dbh;

package EB::Report::Journal::Html;

use strict;
use EB;
use EB::Finance;
use EB::Report::HTML;

use base qw(EB::Report::GenBase);

sub new {
    my ($class, $opts) = @_;
    my $self = $class->SUPER::new($opts);
    $self;
}

sub outline {
    my ($self, $type, @args) = @_;

    my ($date, $bsk, $nr, $loc, $acc, $deb, $crd, $bsr, $rel) = ('') x 9;

    my $cc = "c_gbk";
    my $rc = "";
    if ( $type eq 'H' ) {
	($date, $bsk, $nr, $loc, $bsr) = @args;
	$bsk = $loc;
	$bsk .=  ":" . $nr if $nr;
	$cc = "c_bsk";
	$rc = "r_bsk";
    }

    elsif ( $type eq 'D' ) {
	($date, $bsk, $acc, $deb, $crd, $bsr, $rel) = @args;
	for ( $deb, $crd ) {
	    $_ = $_ ? numfmt($_) : '';
	}
    }

    elsif ( $type eq 'T' ) {
	($bsk, $deb, $crd) = @args;
	for ( $deb, $crd ) {
	    $_ = $_ ? numfmt($_) : '';
	}
	$cc = "c_bsk";
	$rc = "r_tot";
    }
    elsif ( $type eq ' ' ) {
    }
    else {
	die("?".__x("Programmafout: verkeerd type in {here}",
		    here => __PACKAGE__ . "::_repline")."\n");
    }

    $rc = " class=\"$rc\"" if $rc;
    $self->{fh}->print
      ("<tr$rc>",
       $self->{design} ? ("<td class=\"h_typ\">", $type, "</td>\n") : (),
       "<td class=\"c_dat\">", html($date), "</td>\n",
       "<td class=\"$cc\">", html($bsk),  "</td>\n",
       "<td class=\"c_acc\">", html($acc),  "</td>\n",
       "<td class=\"c_deb\">", html($deb),  "</td>\n",
       "<td class=\"c_crd\">", html($crd),  "</td>\n",
       "<td class=\"c_bsr\">", html($bsr),  "</td>\n",
       "<td class=\"c_rel\">", html($rel),  "</td>\n",
       "</tr>\n"
      );

}

sub start {
    my ($self, $t1, $t2) = @_;
    my $reptype = "journaal";
    my $adm;
    if ( $self->{boekjaar} ) {
	$adm = $dbh->lookup($self->{boekjaar},
			    qw(Boekjaren bky_code bky_name));
    }
    else {
	$adm = $dbh->adm("name");
    }

    $self->{fh}->print
      ("<html>\n",
       "<head>\n",
       "<title>", html($t1), "</title>\n",
       '<link rel="stylesheet" href="css/', $self->{style} || $reptype, '.css">', "\n",
       "</head>\n",
       "<body>\n",
       "<p class=\"title\">", html($t1), "</p>\n",
       "<p class=\"subtitle\">", html($adm), "<br>\n", html($t2), "</p>\n",
       "<table class=\"main\">\n");

    $self->{fh}->print
      ("<tr>",
       $self->{design} ? ("<th class=\"h_typ\">", html(_T("Type")), "</th>\n") : (),
       "<th class=\"h_dat\">", html(_T("Datum")),              "</th>\n",
       "<th class=\"h_bsk\">", html(_T("Boekstuk/Grootboek")), "</th>\n",
       "<th class=\"h_acc\">", html(_T("Rek")),                "</th>\n",
       "<th class=\"h_deb\">", html(_T("Debet")),              "</th>\n",
       "<th class=\"h_crd\">", html(_T("Credit")),             "</th>\n",
       "<th class=\"h_bsr\">", html(_T("Boekstuk/regel")),     "</th>\n",
       "<th class=\"h_rel\">", html(_T("Relatie")),            "</th>\n",
       "</tr>\n"
      );
}

sub finish {
    my ($self) = @_;
    $self->{fh}->print("</table>\n");

    my $now = $ENV{EB_SQL_NOW} || iso8601date();
    my $ident = $EB::ident;
    $ident = (split(' ', $ident))[0] if $ENV{EB_SQL_NOW};

    $self->{fh}->print("<p class=\"footer\">",
		       __x("Overzicht aangemaakt op {date} door <a href=\"{url}\">{ident}</a>",
			   ident => $ident, date => $now, url => $EB::url), "</p>\n");
    $self->{fh}->print("</body>\n",
		       "</html>\n");
    close($self->{fh});
}

1;
