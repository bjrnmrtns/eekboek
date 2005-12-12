#!/usr/bin/perl -w
my $RCS_Id = '$Id: DB.pm,v 1.29 2005/12/12 10:53:01 jv Exp $ ';

# Author          : Johan Vromans
# Created On      : Sat May  7 09:18:15 2005
# Last Modified By: Johan Vromans
# Last Modified On: Mon Dec 12 11:40:37 2005
# Update Count    : 249
# Status          : Unknown, Use with caution!

################ Common stuff ################

package EB::DB;

use strict;

use EB;
use DBI;

my $postgres = 1;		# PostgreSQL

my $dbh;			# singleton for DB
my $db;				# singleton for EBDB

my $verbose = 0;
my $trace = 0;

################ high level ################

sub check_db {
    my ($self) = @_;

    my $fail = 0;

    # Check the existence of the required tables.
    my %tables = map { lc, 1 } $dbh->tables;

    foreach my $table ( qw(constants standaardrekeningen verdichtingen accounts
			   relaties accounts boekstukken boekstukregels
			   btwtabel journal metadata) ) {
	next if $tables{$table} || $tables{"public.$table"};
	$fail++;
	 warn("?".__x("Tabel {table} ontbreekt in database {db}",
		      table => $table, db => $dbh->{Name}) . "\n");
    }
    # warn(join(" ", sort keys %tables)."\n") if $fail;
    die("?".__x("Ongeldige EekBoek database: {db}.",
		db => $dbh->{Name}) . " " .
	_T("Wellicht is de database nog niet ge�nitialiseerd?")."\n") if $fail;

    # Check version, and try automatic upgrade.
    my ($maj, $min, $rev)
      = @{$self->do("SELECT adm_scm_majversion, adm_scm_minversion, adm_scm_revision".
		    " FROM Metadata")};
    while ( !($maj == SCM_MAJVERSION &&
	      sprintf("%03d%03d", $min, $rev) eq sprintf("%03d%03d", SCM_MINVERSION, SCM_REVISION)) ) {
	# Basically, this will migrate to the highest possibly version, and then retry.
	my $cur = sprintf("%03d%03d%03d", $maj, $min, $rev);
	my $tmpl = EB_LIB . "EB/migrate/$cur?????????.*l";
	my @a = reverse sort glob($tmpl);
	last unless @a == 1;

	if ( $a[0] =~ /\.sql$/ && open(my $fh, "<$a[0]")) {
	    warn("!"._T("De database wordt aangepast aan de nieuwere versie")."\n");

	    local($/);		# slurp mode
	    my $sql = <$fh>;	# slurp
	    close($fh);

	    require EB::Tools::SQLEngine;
	    eval {
		EB::Tools::SQLEngine->new(dbh => $dbh, trace => $trace)->process($sql);
	    };
	    warn("?".$@) if $@;
	    $dbh->rollback if $@;

	}
	elsif ( $a[0] =~ /\.pl$/ ) {
	    warn("!"._T("De database wordt aangepast aan de nieuwere versie")."\n");
	    my $sd = $::dbh;
	    $::dbh = $self;
	    eval { require $a[0] };
	    $::dbh = $sd;
	    warn("?".$@) if $@;
	}
	($maj, $min, $rev)
	  = @{$self->do("SELECT adm_scm_majversion, adm_scm_minversion, adm_scm_revision".
			" FROM Metadata")};
	die("?"._T("De migratie is mislukt. Gelieve de documentatie te raadplegen.")."\n")
	  if $cur eq sprintf("%03d%03d%03d", $maj, $min, $rev);
    }
    die("?".__x("Ongeldige EekBoek database: {db} versie {ver}.".
		" Benodigde versie is {req}.",
		db => $dbh->{Name}, ver => "$maj.$min.$rev",
		req => join(".", SCM_MAJVERSION, SCM_MINVERSION, SCM_REVISION)) . "\n")
      unless $maj == SCM_MAJVERSION &&
	sprintf("%03d%03d", $min, $rev) eq sprintf("%03d%03d", SCM_MINVERSION, SCM_REVISION);

    # Verify koppelingen.
    for ( $self->std_acc("deb") ) {
	my $rr = $self->do("SELECT acc_debcrd, acc_balres FROM Accounts where acc_id = ?", $_);
	$fail++, warn("?".__x("Geen grootboekrekening voor {dc} ({acct})",
			      dc => _T("Debiteuren"), acct => $_)."\n")
	  unless $rr;
	# $fail++,
	warn("?".__x("Foutieve grootboekrekening voor {dc} ({acct})",
		     dc => _T("Debiteuren"), acct => $_)."\n")
	  unless $rr->[0] && $rr->[1];
    }

    for ( $self->std_acc("crd") ) {
	my $rr = $self->do("SELECT acc_debcrd, acc_balres FROM Accounts where acc_id = ?", $_);
	$fail++, warn("?".__x("Geen grootboekrekening voor {dc} ({acct})",
			      dc => _T("Crediteuren"), acct => $_)."\n")
	  unless $rr;
	# $fail++,
	warn("?".__x("Foutieve grootboekrekening voor {dc} ({acct})",
		     dc => _T("Crediteuren"), acct => $_)."\n")
	  if $rr->[0] || !$rr->[1];
    }

    for ( $self->std_acc("btw_ok") ) {
	my $rr = $self->do("SELECT acc_balres FROM Accounts where acc_id = ?", $_);
	$fail++, warn("?".__x("Geen grootboekrekening voor {dc} ({acct})",
			      dc => _T("BTW betaald"), acct => $_)."\n")
	  unless $rr;
	warn("?".__x("Foutieve grootboekrekening voor {dc} ({acct})",
		     dc => _T("BTW betaald"), acct => $_)."\n")
	  unless $rr->[0];
    }

    for ( $self->std_acc("winst") ) {
	my $rr = $self->do("SELECT acc_balres FROM Accounts where acc_id = ?", $_);
	$fail++, warn("?".__x("Geen grootboekrekening voor {dc} ({acct})",
			      dc => _T("overboeking winst"), acct => $_)."\n")
	  unless $rr;
	warn("?".__x("Foutieve grootboekrekening voor {dc} ({acct})",
		     dc => _T("overboeking winst"), acct => $_)."\n")
	  unless $rr->[0];
    }

    # Verify some grootboekrekeningen.
    my $sth = $self->sql_exec("SELECT acc_id, acc_desc, dbk_id, dbk_type, dbk_desc FROM Dagboeken, Accounts".
			      " WHERE dbk_acc_id = acc_id");
    while ( my $rr = $sth->fetchrow_arrayref ) {
	my ($acc_id, $acc_desc, $dbk_id, $dbk_type, $dbk_desc) = @$rr;
	if ( $dbk_type == DBKTYPE_INKOOP && $acc_id != $self->std_acc("crd") ) {
	    $fail++;
	    warn("?".__x("Verkeerde grootboekrekening {acct} ({adesc}) voor dagboek {dbk} ({ddesc})",
			 acct => $acc_id, adesc => $acc_desc, dbk => $dbk_id, ddesc => $dbk_desc)."\n")
	}
	elsif ( $dbk_type == DBKTYPE_VERKOOP && $acc_id != $self->std_acc("deb") ) {
	    $fail++;
	    warn("?".__x("Verkeerde grootboekrekening {acct} ({adesc}) voor dagboek {dbk} ({ddesc})",
			 acct => $acc_id, adesc => $acc_desc, dbk => $dbk_id, ddesc => $dbk_desc)."\n")
	}
    }

    die("?"._T("CONSISTENTIE-VERIFICATIE STANDAARDREKENINGEN MISLUKT")."\n") if $fail;

    # Create temp table for account mangling.
    $dbh->do("SELECT * INTO TEMP TAccounts FROM Accounts WHERE acc_id = 0");
    # Make it semi-permanent (this connection only).
    $dbh->commit;
}

sub upd_account {
    my ($self, $acc, $amt) = @_;
    my $op = '+';		# perfectionism
    if ( $amt < 0 ) {
	$amt = -$amt;
	$op = '-';
    }
    $self->sql_exec("UPDATE Accounts".
		    " SET acc_balance = acc_balance $op ?".
		    " WHERE acc_id = ?",
		    $amt, $acc);
}

sub store_journal {
    my ($self, $jnl) = @_;
    foreach ( @$jnl ) {
	$self->sql_insert("Journal",
			  [qw(jnl_date jnl_dbk_id jnl_bsk_id jnl_bsr_date jnl_bsr_seq
			      jnl_acc_id jnl_amount jnl_desc jnl_rel)],
			  @$_);
    }
}

sub bskid {
    my ($self, $nr, $bky) = @_;
    return $nr if $nr =~ /^\d+$/ && !wantarray;

    my $rr;
    $bky = $self->adm("bky") unless defined($bky);

    if ( $nr =~ /^([[:alpha:]][^:]+)(?::([^:]+))?:(\d+)$/ ) {
	$rr = $self->do("SELECT dbk_id, dbk_desc".
			" FROM Dagboeken".
			" WHERE dbk_desc ILIKE ?", $1);
	unless ( $rr ) {
	    return wantarray ? (undef, undef, __x("Onbekend dagboek: {dbk}", dbk => $1)) : undef;
	}
	my ($dbk_id, $dbk_desc) = @$rr;
	if ( defined($2) ) {
	    unless ( defined $self->lookup($2, qw(Boekjaren bky_code bky_code)) ) {
		return wantarray ? (undef, undef, __x("Onbekend boekjaar: {bky}", bky => $2)) : undef;
	    }
	    $bky = $2;
	}
	$rr = $self->do("SELECT bsk_id".
			" FROM Boekstukken".
			" WHERE bsk_nr = ?".
			" AND bsk_bky = ?".
			" AND bsk_dbk_id = ?", $3, $bky, $dbk_id);
	unless ( $rr ) {
	    return wantarray ? (undef, undef, __x("Onbekend boekstuk {bsk} in dagboek {dbk}",
						  dbk => $dbk_desc, bsk => $3)) : undef;
	}
	$bky = $bky eq $self->adm("bky") ? "" : ":$bky";
	return wantarray ? ($rr->[0], "$dbk_desc$bky:$3", undef) : $rr->[0];
    }
    elsif ( $nr =~ /^(\d+)$/ ) {

	$rr = $self->do("SELECT bsk_nr, dbk_id, dbk_desc, bsk_bky".
			" FROM Boekstukken, Dagboeken".
			" WHERE bsk_dbk_id = dbk_id".
			" AND bsk_id = ?", $nr);
	unless ( $rr ) {
	    return wantarray ? (undef, undef, __x("Onbekend boekstuk: {bsk}",
						  bsk => $nr)) : undef;
	}
	my ($bsk_nr, $dbk_id, $dbk_desc, $bsk_bky) = @$rr;
	$bsk_nr =~ s/\s+$//;
	$bky = $bsk_bky eq $self->adm("bky") ? "" : ":$bsk_bky";
	return wantarray ? ($nr, "$dbk_desc$bky:$bsk_nr", undef) : $nr;
    }
    else {
	die("?".__x("Ongeldige boekstukaanduiding: {bsk}", bsk => $nr)."\n");
    }
}

################ low level ################

sub new {
    my ($pkg, %atts) = @_;
    $pkg = ref($pkg) || $pkg;

    $verbose = delete($atts{verbose}) || 0;
    $trace   = delete($atts{trace}) || 0;

    $db = {};
    bless $db, $pkg;
    $db->_init;
    $db;
}

sub _init {
    my ($self) = @_;
}

my %adm;
sub adm {
    my ($self, $name, $value) = @_;
    if ( $name eq "" ) {
	%adm = ();
	return;
    }
    unless ( %adm ) {
	$self->connectdb;
	my $sth = $self->sql_exec("SELECT *".
				  " FROM Metadata, Boekjaren".
				  " WHERE adm_bky = bky_code");
	my $rr = $sth->fetchrow_hashref;
	$sth->finish;
	while ( my($k,$v) = each(%$rr) ) {
	    my $k1 = $k;
	    $k =~ s/^(adm|bky)_//;
	    $adm{lc($k)} = [$k1, $v];
	}
    }
    exists $adm{lc($name)} || die("?".__x("Niet-bestaande administratie-eigenschap: {adm}",
					  adm => $name)."\n");
    $name = lc($name);

    if ( @_ == 3 ) {
	$self->sql_exec("UPDATE Metadata".
			" SET ".$adm{$name}->[0]." = ?", $value)->finish;
	$self->commit;
	$adm{$name}->[1] = $value;
    }
    else {
	defined $adm{$name} ? $adm{$name}->[1] : "";
    }
}

sub dbver {
    my ($self) = @_;
    sprintf("%03d%03d%03d", $self->adm("scm_majversion"),
	    $self->adm("scm_minversion")||0, $self->adm("scm_revision"));

}

my %std_acc;
my @std_acc;
sub std_acc {
    my ($self, $name) = @_;
    if ( $name eq "" ) {
	%std_acc = ();
	@std_acc = ();
	return;
    }
    $self->std_accs unless %std_acc;
    $std_acc{lc($name)} || die("?".__x("Niet-bestaande standaardrekening: {std}",
				       std => $name)."\n");
}

sub std_accs {
    my ($self) = @_;
    unless ( @std_acc ) {
	$self->connectdb;
	my $sth = $self->sql_exec("SELECT * FROM Standaardrekeningen");
	my $rr = $sth->fetchrow_hashref;
	$sth->finish;
	while ( my($k,$v) = each(%$rr) ) {
	    $k =~ s/^std_acc_//;
	    $std_acc{lc($k)} = $v;
	}
	@std_acc = sort(keys(%std_acc));
    }
    \@std_acc;
}

my %accts;
sub accts {
    my ($self, $sel) = @_;
    $sel = $sel ? " WHERE $sel" : "";
    return \%accts if %accts;
    my $sth = $self->sql_exec("SELECT acc_id,acc_desc".
			      " FROM Accounts".
			      $sel.
			      " ORDER BY acc_id");
    my $rr;
    while ( $rr = $sth->fetchrow_arrayref ) {
	$accts{$rr->[0]} = $rr->[1];
    }
    \%accts;
}

sub dbh{
    $dbh;
}

sub adm_open {
    my ($self) = @_;
    $self->connectdb;
    $self->adm("bky") ne BKY_PREVIOUS;
}

sub adm_busy {
    my ($self) = @_;
    $self->connectdb;
    $self->do("SELECT COUNT(*) FROM Journal")->[0];
}

sub connectdb {
    my ($self, $dbname, $nocheck) = @_;

    return $dbh if $dbh;

    $dbname ||= $ENV{EB_DB_NAME};
    $dbname = "eekboek_".$dbname unless $dbname =~ /^eekboek_/;
    $dbname = "dbi:Pg:dbname=" . $dbname;

    $dbh = DBI::->connect($dbname)
      or die("?".__x("Database verbindingsprobleem: {err}",
		     err => $DBI::errstr)."\n");
    $dbh->{RaiseError} = 1;
    $dbh->{AutoCommit} = 0;
    $dbh->{ChopBlanks} = 1;
    $self->check_db unless $nocheck;
    $dbh;
}

sub trace {
    my ($self, $value) = @_;
    my $cur = $trace;
    $trace = !$trace, return $cur unless defined $value;
    $trace = $value;
    $cur;
}

sub sql_insert {
    my ($self, $table, $columns, @args) = @_;
    $self->sql_exec("INSERT INTO $table ".
		    "(" . join(",", @$columns) . ") ".
		    "VALUES (" . join(",", ("?") x @$columns) . ")",
		    @args);
}

my %sth;
my $sql_prep_cache_hits;
my $sql_prep_cache_miss;
sub sql_prep {
    my ($self, $sql) = @_;
    $dbh ||= $self->connectdb();
    if ( defined($sth{$sql}) ) {
	$sql_prep_cache_hits++;
	return $sth{$sql};
    }
    $sql_prep_cache_miss++;
    $sth{$sql} = $dbh->prepare($sql);
}

END {
    warn("SQL Prep Cache: number of hits = ",
	 $sql_prep_cache_hits || 0, ", misses = ",
	 $sql_prep_cache_miss || 0, "\n")
      if %sth && $ENV{EB_SQL_PREP_STATS};
}

sub close {
    my ($self) = @_;
    $dbh->disconnect;
    undef $dbh;
    %sth = ();
    $self->std_acc("");
    $self->adm("");
}

sub show_sql($$@) {
    my ($self, $sql, @args) = @_;
    my @a = map {
	!defined($_) ? "NULL" :
	  /^[0-9]+$/ ? $_ : $dbh->quote($_)
      } @args;
    $sql =~ s/\?/shift(@a)/eg;
    warn("=> $sql;\n");
}

sub sql_exec {
    my ($self, $sql, @args) = @_;
    $dbh ||= $self->connectdb();
    $self->show_sql($sql, @args) if $trace;
    my $sth = $self->sql_prep($sql);
    $sth->execute(@args);
    $sth;
}

sub lookup($$$$$;$) {
    my ($self, $value, $table, $arg, $res, $op) = @_;
    $op ||= "=";
    my $sth = $self->sql_exec("SELECT $res FROM $table".
			      " WHERE $arg $op ?", $value);
    my $rr = $sth->fetchrow_arrayref;
    $sth->finish;

    return ($rr && defined($rr->[0]) ? $rr->[0] : undef);

}

sub get_value {
    my ($self, $column, $table) = @_;
    my $sth = $self->sql_exec("SELECT $column FROM $table");
    my $rr = $sth->fetchrow_arrayref;
    $sth->finish;

    return ($rr && defined($rr->[0]) ? $rr->[0] : undef);
}

sub get_sequence {
    my ($self, $seq, $noinc) = @_;
    my $sth = $self->sql_exec("SELECT ".
			      ($noinc ? "currval" : "nextval").
			      "('$seq')");
    my $rr = $sth->fetchrow_arrayref;
    $sth->finish;

    return ($rr && defined($rr->[0]) ? $rr->[0] : undef);
}

sub set_sequence {
    my ($self, $seq, $value) = @_;
    # Init a sequence to value.
    # The next call to get_sequence will return this value.
    $self->sql_exec("SELECT setval('$seq', $value, false)")->finish;
    $value;
}

sub do {
    my $self = shift;
    my $sql = shift;
    my $atts = ref($_[0]) eq 'HASH' ? shift : undef;
    my @args = @_;
    my $sth = $self->sql_exec($sql, @args);
    my $rr = $sth->fetchrow_arrayref;
    $sth->finish;
    $rr;
}

sub errstr {
    $dbh->errstr;
}

sub rollback {
    my ($self) = @_;
    warn("=> ROLLBACK WORK;", $dbh ? "" : " (ignored)", "\n") if $trace;
    return unless $dbh;
    $dbh->rollback
}

sub begin_work {
    my ($self) = @_;
    warn("=> BEGIN WORK;", $dbh ? "" : " (ignored)", "\n") if $trace;
    return unless $dbh;
    $dbh->begin_work;
}

sub commit {
    my ($self) = @_;
    warn("=> COMMIT WORK;", $dbh ? "" : " (ignored)", "\n") if $trace;
    return unless $dbh;
    $dbh->commit;
}

sub disconnectdb {
    my ($self) = @_;

    return unless $dbh;
    $dbh->disconnect;
}

END {
    disconnectdb();
}

1;
