#!/usr/bin/perl -w
my $RCS_Id = '$Id: BKM.pm,v 1.41 2006/02/07 11:42:56 jv Exp $ ';

package main;

our $cfg;
our $dbh;
our $app;
our $config;

package EB::Booking::BKM;

# Author          : Johan Vromans
# Created On      : Thu Jul  7 14:50:41 2005
# Last Modified By: Johan Vromans
# Last Modified On: Mon Feb  6 12:52:02 2006
# Update Count    : 336
# Status          : Unknown, Use with caution!

################ Common stuff ################

use strict;
use warnings;

# Dagboek type 3: Bank
# Dagboek type 4: Kas
# Dagboek type 5: Memoriaal

use EB;
use EB::DB;
use EB::Finance;
use EB::Report::Journal;
use base qw(EB::Booking);

my $trace_updates = $cfg->val(__PACKAGE__, "trace_updates", 0);	# for debugging

sub perform {
    my ($self, $args, $opts) = @_;

    return unless $self->adm_open;

    my $dagboek = $opts->{dagboek};
    my $dagboek_type = $opts->{dagboek_type};
    my $totaal = $opts->{totaal};
    my $saldo = $opts->{saldo};

    if ( defined($totaal) ) {
	my $t = amount($totaal);
	return "?".__x("Ongeldig totaal: {total}", total => $totaal)
	  unless defined $t;
	$totaal = $t;
    }

    if ( defined($saldo) ) {
	my $t = amount($saldo);
	return "?".__x("Ongeldig saldo: {saldo}", saldo => $saldo)
	  unless defined $t;
	$saldo = $t;
    }

    my $bky = $self->{bky} ||= $opts->{boekjaar} || $dbh->adm("bky");

    my ($begin, $end);
    return unless ($begin, $end) = $self->begindate;

    my $date;
    if ( $date = parse_date($args->[0], substr($begin, 0, 4)) ) {
	shift(@$args);
    }
    else {
	return "?".__x("Onherkenbare datum: {date}",
		       date => $args->[0])."\n"
	  if ($args->[0]||"") =~ /^[[:digit:]]/;
	$date = iso8601date();
    }

    return "?"._T("Deze opdracht is onvolledig. Gebruik de \"help\" opdracht voor meer aanwijzingen.")."\n"
      unless @$args;

    return unless $self->in_bky($date, $begin, $end);

    my $gdesc = shift(@$args);

    my $nr = 1;
    my $bsk_id;
    my $gacct = $dbh->lookup($dagboek, qw(Dagboeken dbk_id dbk_acc_id));

    print(__x("Huidig saldo: {bal}",
	      bal => numfmt($dbh->lookup($gacct, qw(Accounts acc_id acc_balance)))), "\n")
      if $gacct;

    my $bsk_nr = $self->bsk_nr($opts);
    $dbh->sql_insert("Boekstukken",
		     [qw(bsk_nr bsk_desc bsk_dbk_id bsk_date bsk_bky)],
		     $bsk_nr, $gdesc, $dagboek, $date, $bky);
    $bsk_id = $dbh->get_sequence("boekstukken_bsk_id_seq", "noincr");
    my $tot = 0;
    my $did = 0;
    my $fail = 0;

    while ( @$args ) {
	my $type = shift(@$args);

	if ( $type eq "std" ) {
	    return "?"._T("Deze opdracht is onvolledig. Gebruik de \"help\" opdracht voor meer aanwijzingen.")."\n"
	      unless @$args >= 3;
	    my $dd = parse_date($args->[0], substr($begin, 0, 4));
	    if ( $dd ) {
		shift(@$args);
		return unless $self->in_bky($dd, $begin, $end);
		if ( $dbh->adm("btwbegin") && $dd lt $dbh->adm("btwbegin") ) {
		    warn("?"._T("De boekingsdatum valt in de periode waarover al BTW aangifte is gedaan")."\n");
		    return;
		}
	    }
	    else {
		return "?".__x("Onherkenbare datum: {date}",
			       date => $args->[0])."\n"
		  if ($args->[0]||"") =~ /^[[:digit:]]/;
		$dd = $date;
	    }
	    return "?"._T("Deze opdracht is onvolledig. Gebruik de \"help\" opdracht voor meer aanwijzingen.")."\n"
	      unless @$args >= 3;

	    my ($desc, $amt, $acct) = splice(@$args, 0, 3);
	    if ( $did++ || @$args || $opts->{verbose} ) {
		my $t = $desc;
		$t = '"' . $desc . '"' if $t =~ /\s/;
		warn(" "._T("boekstuk").": std $t $amt $acct\n");
	    }

	    my $dc = "acc_debcrd";
	    my $explicit_dc;
	    if ( $acct =~ /^(\d+)([cd])/i ) {
#		$acct = $1;
#		$explicit_dc = $dc = lc($2) eq 'd' ? 1 : 0;
		warn("?"._T("De \"D\" of \"C\" toevoeging aan het rekeningnummer is hier niet toegestaan")."\n");
		$fail++;
		next;
	    }
	    elsif  ( $acct !~ /^\d+$/ ) {
		warn("?".__x("Ongeldig grootboekrekeningnummer: {acct}", acct => $acct )."\n");
		$fail++;
		next;
	    }
	    $dc = 1;		# ####
	    my $rr = $dbh->do("SELECT acc_desc,acc_balres,$dc,acc_kstomz,acc_btw".
			      " FROM Accounts".
			      " WHERE acc_id = ?", $acct);
	    unless ( $rr ) {
		warn("?".__x("Onbekende grootboekrekening: {acct}",
			     acct => $acct)."\n");
		$fail++;
		next;
	    }
	    my ($adesc, $balres, $debcrd, $kstomz, $btw_id) = @$rr;

	    if ( $balres && $dagboek_type != DBKTYPE_MEMORIAAL ) {
		warn("!".__x("Grootboekrekening {acct} ({desc}) is een balansrekening",
			     acct => $acct, desc => $adesc)."\n") if 0;
		#$dbh->rollback;
		#return;
	    }

	    my $bid;
	    my $oamt = $amt;
	    ($amt, $bid) = amount($amt, undef);
	    unless ( defined($amt) ) {
		warn("?".__x("Ongeldig bedrag: {amt}", amt => $oamt)."\n");
		$fail++;
		next;
	    }
	    $btw_id = 0, undef($bid) if defined($bid) && !$bid; # override: @0

	    # If there's BTW associated, it must be explicitly confirmed.
	    if ( $btw_id && !defined($bid) && $dagboek_type == DBKTYPE_MEMORIAAL ) {
		warn("?".__x("Boekingen met BTW zijn niet mogelijk in een {dbk}.".
			     " De BTW is op nul gesteld.",
			     dbk => $dagboek_type == DBKTYPE_BANK ? "bankboek" :
			     $dagboek_type == DBKTYPE_KAS ? "kasboek" :
			     "memoriaal")."\n");
		$btw_id = 0;
	    }
	    my $btw_acc;
	    if ( defined($bid) ) {
		if ( $bid =~ /^[hl]|[hl][iv]|[iv][hl]$/i ) {
		    $bid = lc($bid);
		    my $t = $bid =~ /h/ ? "h" : "l";
		    if ( $bid =~ /([iv])/ ) {
			$t = $1.$t;
		    }
		    else {
			$t = $amt < 0 ? "i$t" : "v$t";
		    }
		    $btw_acc = $dbh->std_acc("btw_$t");
		    $btw_id = $dbh->do("SELECT btw_id".
				       " FROM BTWTabel".
				       " WHERE btw_tariefgroep = ?".
				       " AND btw_incl",
				       $bid =~ /h/ ? BTWTARIEF_HOOG : BTWTARIEF_LAAG)->[0];
		}
		elsif ( $bid =~ /^\d+|\d+[iv]|[iv]\d+$/i ) {
		    my $t = $btw_id = $1 if $bid =~ /(\d+)/;
		    my $group = $dbh->lookup($t, qw(BTWTabel btw_id btw_tariefgroep));
		    unless ( defined $group ) {
			warn("?".__x("Ongeldige BTW codering: {cod}",
				     cod => '@'.$bid)."\n");
			$fail++;
			next;
		    }
		    if ( $bid =~ /([iv])/ ) {
			$t = $1;
		    }
		    else {
			$t = $kstomz ? "i" : "v";
		    }
		    $t .= $group == BTWTARIEF_HOOG ? "h" : "l";
		    $btw_acc = $dbh->std_acc("btw_$t");
		}
		else {
		    warn("?".__x("Ongeldige BTW codering: {cod}",
				 cod => '@'.$bid)."\n");
		    $fail++;
		    next;
		}
	    }
	    elsif ( $btw_id ) {
		my $tg = $dbh->lookup($btw_id, qw(BTWTabel btw_id btw_tariefgroep));
		croak("INTERNAL ERROR: btw code $btw_id heeft tariefgroep $tg")
		  unless $tg;
		my $t = qw(v i)[$kstomz] . qw(x h l)[$tg];
		$btw_acc = $dbh->std_acc("btw_$t");
	    }

	    my $btw = 0;
	    my $bsr_amount = $amt;
	    my $orig_amount = $amt;
	    my ($btw_ink, $btw_verk);
	    if ( $btw_id ) {
		( $bsr_amount, $btw, $btw_ink, $btw_verk ) =
		  @{EB::Finance::norm_btw($bsr_amount, $btw_id)};
		$amt = $bsr_amount - $btw;
	    }
	    $orig_amount = -$orig_amount;# unless $debcrd;

	    $dbh->sql_insert("Boekstukregels",
			     [qw(bsr_nr bsr_date bsr_bsk_id bsr_desc bsr_amount
				 bsr_btw_id bsr_btw_acc bsr_btw_class bsr_type
				 bsr_acc_id bsr_rel_code)],
			     $nr++, $dd, $bsk_id, $desc, $orig_amount,
			     $btw_id, $btw_acc,
			     BTWKLASSE(1, BTWTYPE_NORMAAL, $balres ? 1 : $kstomz),
			     0, $acct, undef);

	    warn("update $acct with ".numfmt(-$amt)."\n") if $trace_updates;
	    $dbh->upd_account($acct, -$amt);
	    $tot += $amt;

	    if ( $btw ) {
		my $btw_acct =
		  $dbh->lookup($acct, qw(Accounts acc_id acc_debcrd)) ? $btw_ink : $btw_verk;
		warn("update $btw_acct with ".numfmt(-$btw)."\n") if $trace_updates;
		$dbh->upd_account($btw_acct, -$btw);
		$tot += $btw;
	    }


	}
	elsif ( $type eq "deb" || $type eq "crd" ) {
	    my $debcrd = $type eq "deb" ? 1 : 0;
	    return "?"._T("Deze opdracht is onvolledig. Gebruik de \"help\" opdracht voor meer aanwijzingen.")."\n"
	      unless @$args >= 2;
	    my $dd = parse_date($args->[0], substr($begin, 0, 4));
	    if ( $dd ) {
		shift(@$args);
		return unless $self->in_bky($dd, $begin, $end);
		if ( $dbh->adm("btwbegin") && $dd lt $dbh->adm("btwbegin") ) {
		    warn("?"._T("De boekingsdatum valt in de periode waarover al BTW aangifte is gedaan")."\n");
		    return;
		}
	    }
	    else {
		return "?".__x("Onherkenbare datum: {date}",
			       date => $args->[0])."\n"
		  if ($args->[0]||"") =~ /^[[:digit:]]/;
		$dd = $date;
	    }
	    return "?"._T("Deze opdracht is onvolledig. Gebruik de \"help\" opdracht voor meer aanwijzingen.")."\n"
	      unless @$args >= 2;

	    my ($rel, $amt) = splice(@$args, 0, 2);
	    warn(" "._T("boekstuk").": $type $rel $amt\n")
	      if $did++ || @$args || $opts->{verbose};

	    my $oamt = $amt;
	    $amt = amount($amt);
	    unless ( defined($amt) ) {
		warn("?".__x("Ongeldig bedrag: {amt}", amt => $oamt)."\n");
		$fail++;
		next;
	    }

	    my ($rr, $sql, @sql_args);
	    if ( $rel =~ /:/ ) {
		my ($id, $bsk, $err) = $dbh->bskid($rel);
		unless ( defined($id) ) {
		    warn("?$err\n");
		    $fail++;
		    next;
		}
		$sql = "SELECT bsk_id, dbk_id, bsk_desc, bsk_amount, bsr_rel_code".
		  " FROM Boekstukken, Boekstukregels, Dagboeken" .
		    " WHERE bsk_id = ?".
		      "  AND bsk_dbk_id = dbk_id".
			"  AND bsr_bsk_id = bsk_id".
			  " AND bsr_nr = 1".
			    "  AND dbk_type = ?";
		@sql_args = ( $id, $debcrd ? DBKTYPE_VERKOOP : DBKTYPE_INKOOP);
		$rr = $dbh->do($sql, @sql_args);
		unless ( defined($rr) ) {
		    warn("?"._T("Geen bijbehorende open post gevonden")."\n");
		    #warn("DEBUG: SQL: $sql\n");
		    #warn("DEBUG: args: @sql_args\n");
		    $fail++;
		    next;
		}
	    }
	    else {
		# Lookup rel code.
		$rr = $dbh->do("SELECT rel_code FROM Relaties" .
			       " WHERE upper(rel_code) = ?" .
			       "  AND " . ($debcrd ? "" : "NOT ") . "rel_debcrd",
			       uc($rel));
		unless ( defined($rr) ) {
		    warn("?".__x("Onbekende {what}: {who}",
				 what => lc($type eq "deb" ? _T("Debiteur") : _T("Crediteur")),
				 who => $rel)."\n");
		    $fail++;
		    next;
		}
		# Get actuqal code.
		$rel = $rr->[0];

		# Find associated booking.
		$sql = "SELECT bsk_id, dbk_id, bsk_desc, bsk_amount ".
		  " FROM Boekstukken, Boekstukregels, Dagboeken" .
		    " WHERE bsk_open != 0".
		      ($amt ? "  AND bsk_open = ?" : "").
			"  AND dbk_type = ?".
			  "  AND bsk_dbk_id = dbk_id".
			    "  AND bsr_bsk_id = bsk_id".
			      "  AND bsr_rel_code = ?".
				" ORDER BY bsk_id";
		@sql_args = ( $amt ? $amt : (),
			       $debcrd ? DBKTYPE_VERKOOP : DBKTYPE_INKOOP,
			      $rel);
		$rr = $dbh->do($sql, @sql_args);
		unless ( defined($rr) ) {
		    warn("?"._T("Geen bijbehorende open post gevonden")."\n");
		    #warn("DEBUG: SQL: $sql\n");
		    #warn("DEBUG: args: @sql_args\n");
		    $fail++;
		    next;
		}
		$rr = [@$rr, $rel];
	    }

	    my ($bskid, $dbk_id, $bsk_desc, $bsk_amount, $bsr_rel) = @$rr;
	    my $acct = $dbh->std_acc($debcrd ? "deb" : "crd");

	    $dbh->sql_insert("Boekstukregels",
			     [qw(bsr_nr bsr_date bsr_bsk_id bsr_desc bsr_amount
				 bsr_btw_id bsr_type bsr_acc_id bsr_btw_class
				 bsr_rel_code bsr_paid)],
			     $nr++, $dd, $bsk_id, "*".$bsk_desc, -$amt, 0,
			     $type eq "deb" ? 1 : 2, $acct, 0, $bsr_rel, $bskid);
	    my $id = $dbh->get_sequence("boekstukregels_bsr_id_seq", "noincr");
	    $dbh->sql_exec("UPDATE Boekstukken".
			   " SET bsk_open = bsk_open - ?".
			   " WHERE bsk_id = ?",
			   $amt, $bskid);

	    warn("update $acct with ".numfmt(-$amt)."\n") if $trace_updates;
	    $dbh->upd_account($acct, -$amt);
	    $tot += $amt;
	}
	else {
	    warn("?".__x("Onbekend transactietype: {type}", type => $type)."\n");
	    $fail++;
	    next;
	}
    }

    if ( $gacct ) {
	warn("update $gacct with ".numfmt($tot)."\n") if $trace_updates;
	$dbh->upd_account($gacct, $tot);
	my $new = $dbh->lookup($gacct, qw(Accounts acc_id acc_balance));
	print(__x("Nieuw saldo: {bal}", bal => numfmt($new)), "\n");
	$dbh->sql_exec("UPDATE Boekstukken SET bsk_saldo = ? WHERE bsk_id = ?",
		       $new, $bsk_id)->finish;
	if ( defined $saldo ) {
	    unless ( $saldo == $new ) {
		warn("?".__x("Saldo {new} klopt niet met de vereiste waarde {act}",
			     new => numfmt($new), act => numfmt($saldo))."\n");
		$fail++;
	    }
	}
	if ( defined($totaal) and $tot != $totaal ) {
	    $fail++;
	    return "?"._T("Opdracht niet uitgevoerd.")." ".
	      __x(" Boekstuk totaal is {act} in plaats van {exp}",
		  act => numfmt($tot), exp => numfmt($totaal)) . ".";
	}
    }
    elsif ( $tot ) {
	warn("?".__x("Boekstuk is niet in balans (verschil is {diff})",
		     diff => numfmt($tot))."\n");
	$fail++;
    }
    $dbh->sql_exec("UPDATE Boekstukken SET bsk_amount = ? WHERE bsk_id = ?",
		   $tot, $bsk_id)->finish;

    $dbh->store_journal(EB::Finance::journalise($bsk_id));

    if ( $opts->{journal} ) {
	warn("?"._T("Dit overicht is ter referentie, de boeking is niet uitgevoerd!")."\n") if $fail;
	EB::Report::Journal->new->journal
	    ({select => $bsk_id,
	      d_boekjaar => $bky,
	      detail => 1});
    }

    if ( $fail ) {
	warn("?"._T("De boeking is niet uitgevoerd!")."\n");
	$dbh->rollback;
	return undef;
    }
    $dbh->commit;

    join(":", $dbh->lookup($dagboek, qw(Dagboeken dbk_id dbk_desc)), $bsk_nr);
}

1;
