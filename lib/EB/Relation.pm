#!/usr/bin/perl -w

package main;

our $dbh;

package EB::Relation;

use EB;

use strict;

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $self = {};
    bless $self => $class;
    $self->add(@_) if @_;
    $self;
}

sub add {
    my ($self, $code, $desc, $acct, $opts) = @_;
    my $bstate = $opts->{btw};
    my $dbk = $opts->{dagboek};

    if ( defined($bstate) ) {
	$bstate = lc($bstate);
	if ( $bstate =~ /^\d+$/ && $bstate >= 0 && $bstate <= 3 ) { #### TODO
	    # Ok.
	}
	elsif ( $bstate eq "normaal" ) { $bstate = BTW_NORMAAL }
	elsif ( $bstate eq "verlegd" ) { $bstate = BTW_VERLEGD }
	elsif ( $bstate eq "intra" )   { $bstate = BTW_INTRA   }
	elsif ( $bstate eq "extra" )   { $bstate = BTW_EXTRA   }
	else {
	    warn("?".__x("Ongeldige waarde voor BTW status: {btw}", btw => $bstate)."\n");
	    return;
	}
    }
    my $debiteur;
    my $ddesc;
    if ( $dbk ) {
	my $rr = $dbh->do("SELECT dbk_id, dbk_type, dbk_desc".
			       " FROM Dagboeken".
			       " WHERE dbk_desc ILIKE ?",
			  $dbk);
	unless ( $rr ) {
	    warn("?".__x("Onbekend dagboek: {dbk}", dbk => $dbk)."\n");
	    return;
	}
	my ($id, $type, $desc) = @$rr;
	if ( $type == DBKTYPE_INKOOP ) {
	    $debiteur = 0;
	}
	elsif ( $type == DBKTYPE_VERKOOP ) {
	    $debiteur = 1;
	}
	else {
	    warn("?".__x("Ongeldig dagboek voor relatie: {dbk}", dbk => $dbk)."\n");
	    return;
	}
	$dbk = $id;
	$ddesc = $desc;
    }

    # Invoeren nieuwe relatie.

    # Koppeling debiteur/crediteur op basis van debcrd van de
    # bijbehorende grootboekrekening.

    # Koppeling met dagboek op basis van het laagstgenummerde
    # inkoop/verkoop dagboek (tenzij meegegeven).

    my $dbcd = "acc_debcrd";
    if ( $acct =~ /^(\d+)([DC]$)/i) {
	$acct = $1;
	$dbcd = uc($2) eq 'D' ? 1 : 0; # Note: D -> Crediteur
	if ( defined($debiteur) && $dbcd == $debiteur ) {
	    warn("?".__x("Dagboek {dbk} implicieert {typ1} maar {acct} impliceert {typ2}",
			 dbk => $ddesc,
			 typ1 => lc($debiteur ? _T("Debiteur") : _T("Crediteur")),
			 acct => $acct.$2,
			 typ2 => lc($dbcd ? _T("Crediteur") : _T("Debiteur")))."\n");
	    return;
	}
    }

    my $rr = $dbh->do("SELECT acc_desc,acc_balres,$dbcd".
			" FROM Accounts".
			" WHERE acc_id = ?", $acct);
    unless ( $rr ) {
	warn("?".__x("Onbekende grootboekrekening: {acct}", acct => $acct). "\n");
	return;
    }
    my ($adesc, $balres, $debcrd) = @$rr;
    if ( $balres ) {
	warn("?".__x("Grootboekrekening {acct} ({desc}) is een balansrekening",
		     acct => $acct, desc => $adesc)."\n");
	return;
    }
    $debcrd = defined($debiteur) ? $debiteur : 1 - $debcrd;

    unless ( $dbk ) {
	my $sth = $dbh->sql_exec("SELECT dbk_id, dbk_desc".
				 " FROM Dagboeken".
				 " WHERE dbk_type = ?".
				 " ORDER BY dbk_id",
				 $debcrd ? DBKTYPE_VERKOOP : DBKTYPE_INKOOP);
	$rr = $sth->fetchrow_arrayref;
	$sth->finish;
	($dbk, $ddesc) = @$rr;
    }

    $dbh->sql_insert("Relaties",
		       [qw(rel_code rel_desc rel_debcrd rel_btw_status rel_ledger rel_acc_id)],
		       $code, $desc, $debcrd, $bstate || 0, $dbk, $acct);

    $dbh->commit;
    ($debcrd ? _T("Debiteur") : _T("Crediteur")) . " " . $code .
      " -> $acct ($adesc), dagboek $ddesc";
}

1;
