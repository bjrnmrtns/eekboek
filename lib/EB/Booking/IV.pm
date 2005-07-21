#!/usr/bin/perl -w
my $RCS_Id = '$Id: IV.pm,v 1.7 2005/07/21 10:26:55 jv Exp $ ';

package EB::Booking::IV;

# Author          : Johan Vromans
# Created On      : Thu Jul  7 14:50:41 2005
# Last Modified By: Johan Vromans
# Last Modified On: Thu Jul 21 12:25:40 2005
# Update Count    : 72
# Status          : Unknown, Use with caution!

################ Common stuff ################

use strict;
use warnings;

# Dagboek type 1: Inkoop
# Dagboek type 2: Verkoop

use EB::Globals;
use EB::DB;
use EB::Finance;
use EB::Journal::Text;
use locale;

my $trace_updates = $ENV{EB_TRACE_UPDATES};		# for debugging

sub new {
    return bless {};
}

sub perform {
    my ($self, $args, $opts) = @_;

    my $dagboek = $opts->{dagboek};
    my $dagboek_type = $opts->{dagboek_type};

    my $date;
    if ( $args->[0] =~ /^\d+-\d+-\d+$/ ) {
	$date = shift(@$args);
    }
    else {
	my @tm = localtime(time);
	$date = sprintf("%04d-%02d-%02d",
			1900 + $tm[5], 1 + $tm[4], $tm[3]);
    }

    my $debcode;
    my $rr;
    if ( $dagboek_type == DBKTYPE_INKOOP
	 || $dagboek_type == DBKTYPE_VERKOOP ) {
	$debcode = shift(@$args);
	$rr = $::dbh->do("SELECT rel_acc_id, rel_btw_status FROM Relaties" .
			 " WHERE rel_code = ?" .
			 "  AND " . ($dagboek_type == DBKTYPE_INKOOP ? "NOT " : "") . "rel_debcrd" .
			 "  AND rel_ledger = ?",
			 $debcode, $dagboek);
	unless ( defined($rr) ) {
	    warn("?Onbekende ".
		 ($dagboek_type == DBKTYPE_INKOOP ? "crediteur" : "debiteur").
		 ": $debcode\n");
	    $::dbh->rollback;
	    return;
	}
    }
    else {
	warn("?Ongeldige operatie (IV) voor dagboek type $dagboek_type\n");
	$::dbh->rollback;
	return;
    }

    my ($rel_acc_id, $sbtw) = @$rr;

    my $nr = 1;
    my $bsk_id;
    my $gdesc;
    my $did = 0;

    while ( @$args ) {
	my ($desc, $amt, $acct) = splice(@$args, 0, 3);
	$acct ||= $rr->[0];
	warn(" add$dagboek $desc $amt $acct\n")
	  if $did++ || @$args || $opts->{verbose};

	my $rr = $::dbh->do("SELECT acc_desc,acc_balres,acc_debcrd,acc_btw".
			    " FROM Accounts".
			    " WHERE acc_id = ?", $acct);
	unless ( $rr ) {
	    warn("?Onbekende grootboekrekening: $acct\n");
	    $::dbh->rollback;
	    return;
	}
	my ($adesc, $balres, $debcrd, $btw_id) = @$rr;

	if ( $balres ) {
	    warn("!Rekening $acct ($adesc) is een balansrekening\n");
	    #$::dbh->rollback;
	    #return;
	}

	if ( $nr == 1 ) {
	    $::dbh->sql_insert("Boekstukken",
			     [qw(bsk_nr bsk_desc bsk_dbk_id bsk_date bsk_paid)],
			     $::dbh->get_sequence("bsk_nr_${dagboek}_seq"),
			     $desc, $dagboek, $date, undef);
	    $gdesc = $desc;
	    $bsk_id = $::dbh->get_sequence("boekstukken_bsk_id_seq", "noincr");
	}

	# btw_id    btw_acc
	#   0         \N          zonder BTW, extra/verlegd
	#   0         nnnn        zonder BTW
	#   n         nnnn        normaal
	#   n         \N          extra/verlegd

	# Amount can override BTW id with @X postfix.
	($amt, $btw_id) = amount($amt, $btw_id);

	my $btw_acc;
	# Geen BTW voor non-EU.
	if ( $btw_id && ($sbtw == BTW_NORMAAL || $sbtw == BTW_INTRA) ) {
	    ($btw_acc) = @{$::dbh->do("SELECT ".
				      ($dagboek_type == DBKTYPE_INKOOP ? "btg_acc_inkoop" : "btg_acc_verkoop").
				      " FROM BTWTabel, BTWTariefgroepen".
				      " WHERE btw_tariefgroep = btg_id AND btw_id = ?",
				      $btw_id)};
	    die("D/C mismatch, accounts $acct <> $btw_acc")
	      unless $::dbh->lookup($acct,
				    qw(Accounts acc_id acc_debcrd))
		^ $::dbh->lookup($btw_acc,
				    qw(Accounts acc_id acc_debcrd));
	}

	$::dbh->sql_insert("Boekstukregels",
			 [qw(bsr_nr bsr_date bsr_bsk_id bsr_desc bsr_amount
			     bsr_btw_id bsr_btw_acc bsr_type bsr_acc_id bsr_rel_code)],
			 $nr++, $date, $bsk_id, $desc, $amt,
			 $btw_id, $btw_acc, 0, $acct, $debcode);
    }

    my $ret = EB::Finance::journalise($bsk_id);
    $rr = [ @$ret ];
    shift(@$rr);
    $rr = [ sort { $a->[4] <=> $b->[4] } @$rr ];
    foreach my $r ( @$rr ) {
	my (undef, undef, undef, $nr, $ac, $amt) = @$r;
	next unless $nr;
	warn("update $ac with ".numfmt($amt)."\n") if $trace_updates;
	$::dbh->upd_account($ac, $amt);
    }
    $::dbh->sql_exec("UPDATE Boekstukken SET bsk_amount = ? WHERE bsk_id = ?",
		     $ret->[$#{$ret}]->[5], $bsk_id)->finish;

    $::dbh->store_journal($ret);

    $::dbh->commit;

    EB::Journal::Text->new->journal($bsk_id) if $opts->{journal};

    $bsk_id;
}

1;
