#! perl

# Postgres.pm -- EekBoek driver for PostgreSQL database
# Author          : Johan Vromans
# Created On      : Tue Jan 24 10:43:00 2006
# Last Modified By: Johan Vromans
# Last Modified On: Thu Sep 24 22:37:02 2015
# Update Count    : 227
# Status          : Unknown, Use with caution!

package main;

our $cfg;

package EB::DB::Postgres;

use strict;
use warnings;

use EB;
use DBI;
use DBD::Pg;

my $dbh;			# singleton
my $dataset;

my $trace = $cfg->val(__PACKAGE__, "trace", 0) if $cfg;

# API: type  type of driver
sub type { "PostgreSQL" }

sub _dsn {
    my $dsn = "dbi:Pg:dbname=" . shift;
    my $t;
    $dsn .= ";host=" . $t if $t = $cfg->val(qw(database host), undef);
    $dsn .= ";port=" . $t if $t = $cfg->val(qw(database port), undef);
    wantarray
      ? ( $dsn,
	  $cfg->val("database", "user", undef),
	  $cfg->val("database", "password", undef))
      : $dsn;
}

# API: create a new database, reuse an existing one if possible.
sub create {
    my ($self, $dbname) = @_;

    if ( $dbh && !$dbname ) {	# use current DB.
	$dbh->{RaiseError} = 0;
	$dbh->{PrintError} = 0;
	$dbh->{AutoCommit} = 1;
	$self->clear;
	$dbh->{RaiseError} = 1;
	$dbh->{PrintError} = 1;
#	$dbh->{AutoCommit} = 0;
	return;
    }

    croak("?INTERNAL ERROR: create db while connected") if $dbh;
    eval {
	{
	    local($SIG{__WARN__}) = sub {};
	    $self->connect($dbname);
	}
	$dbh->{RaiseError} = 0;
	$dbh->{PrintError} = 0;
	$dbh->{AutoCommit} = 1;
	$self->clear;
	$self->disconnect;
    };
    return unless $@;
    die($@) if $@ =~ /UNICODE/;

    $dbname =~ s/^(?!=eekboek_)/eekboek_/;

    # Normally, sql treats names as lowcased. By using " " we can
    # maintain the case of the database name.
    my $sql = "CREATE DATABASE \"$dbname\"";
    $sql .= " ENCODING 'UNICODE'";
    for ( $cfg->val("database", "user", undef) ) {
	next unless $_;
	$sql .= " OWNER $_";
    }
    my $dbh = DBI->connect(_dsn("template1"));
    my $errstr = $DBI::errstr;
    if ( $dbh ) {
	warn("+ $sql\n") if $trace;
	$dbh->do($sql);
	$errstr = $DBI::errstr;
	$dbh->disconnect;
	return unless $errstr;
    }
    die("?".__x("Database probleem: {err}",
		err => $errstr)."\n");
}

# API: connect to an existing database.
sub connect {
    my ($self, $dbname) = @_;
    croak("?INTERNAL ERROR: connect db without dataset name") unless $dbname;

    if ( $dataset && $dbh && $dbname eq $dataset ) {
	return $dbh;
    }

    $self->disconnect;

    $dbname = "eekboek_".$dbname unless $dbname =~ /^eekboek_/;
    $cfg->newval(qw(database fullname), $dbname);
    $dbh = DBI::->connect(_dsn($dbname))
      or die("?".__x("Database verbindingsprobleem: {err}",
		     err => $DBI::errstr)."\n");
    $dataset = $dbname;
    my $enc = $dbh->selectall_arrayref("SHOW CLIENT_ENCODING")->[0]->[0];
    if ( $enc !~ /^unicode|utf8$/i ) {
	warn("!".__x("Database {name} is niet in UTF-8 maar {enc}",
		     name => $_[1], enc => $enc)."\n");
    }
    $dbh->do("SET CLIENT_ENCODING TO 'UNICODE'");
    $dbh->{pg_enable_utf8} = 1;
    return $dbh;
}

# API: Disconnect from a database.
sub disconnect {
    my ($self) = @_;
    return unless $dbh;
    $dbh->disconnect;
    undef $dbh;
    undef $dataset;
}

# API: Setup whatever is needed.
sub setup {
}

sub clear {
    my ($self) = @_;
    croak("?INTERNAL ERROR: clear db while not connected") unless $dbh;

    for my $tbl ( qw(Boekstukregels Journal Boekjaarbalans
		     Metadata Standaardrekeningen Relaties
		     Boekstukken Dagboeken Boekjaren Constants
		     Accounts Btwtabel Verdichtingen Taccounts
		     Attachments
		   ) ) {
	warn("+ DROP TABLE $tbl\n") if $trace;
	eval { $dbh->do("DROP TABLE $tbl") };
    }

    eval {
	my $rr = $dbh->selectall_arrayref("SELECT relname".
					  " FROM pg_class".
					  " WHERE relkind = 'S'".
					  ' AND relname LIKE \'%bsk_%_seq\'');
	foreach my $seq ( @$rr ) {
	    warn("+ DROP SEQUENCE $seq->[0]\n") if $trace;
	    eval { $dbh->do("DROP SEQUENCE $seq->[0]") };
	}
    };
    $dbh->commit unless $dbh->{AutoCommit};

}

# API: Test db connection.
sub test {
    my $self = shift;
    my $db = shift;
    $db = $db ? "eekboek_$db" : "template1";
    my $opts = shift || {};
    my $d;
    my $dsn = "dbi:Pg:dbname=$db";
    my $t;
    $dsn .= ";host=" . $t if $t = $opts->{host};
    $dsn .= ";port=" . $t if $t = $opts->{port};
    eval {
	$d = DBI->connect( $dsn,
			   $opts->{user} || undef,
			   $opts->{password} || undef,
			 );
    };
    return $@ if $@;
    return DBI->errstr unless $d;
    $d->{RaiseError} = 1;

    unless ( $db eq "template1" ) {
	# Check if we really can access the db.
	eval {
	    $d->do("SELECT * FROM Metadata");
	};
	return $@ if $@;
	return DBI->errstr unless $d;
    }

    eval {
	$d->disconnect;
    };
    return;
}

# API: List available data sources.
sub list {
    my @ds;

    my $t;
    local $ENV{PGHOST}   = $t if $t = $cfg->val(qw(database host), undef);
    local $ENV{PGPORT}   = $t if $t = $cfg->val(qw(database port), undef);
    local $ENV{DBI_USER} = $t if $t = $cfg->val("database", "user", undef);
    local $ENV{DBI_PASS} = $t if $t = $cfg->val("database", "password", undef);
    eval {
	@ds = DBI->data_sources("Pg");
    };
    # If the list cannot be established, @ds will be (undef).
    return [] unless defined($ds[0]);
    my $d = [];
    foreach ( @ds ) {
	next unless s/^.*?dbname=eekboek_(.+)//;
	push( @$d, $1 );
    }
    return $d;
}

# API: Get a array ref with table names (lowcased).
sub get_tables {
    my $self = shift;
    my @t;
    foreach ( $dbh->tables ) {
	next unless /^public\.(.+)/i;
	push(@t, lc($1));
    }
    \@t;
}

################ Sequences ################

# API: Get the next value for a sequence, incrementing it.
sub get_sequence {
    my ($self, $seq) = @_;
    croak("?INTERNAL ERROR: get sequence while not connected") unless $dbh;

    my $rr = $dbh->selectall_arrayref("SELECT nextval('$seq')");
    return ($rr && defined($rr->[0]) && defined($rr->[0]->[0])? $rr->[0]->[0] : undef);
}

# API: Set the next value for a sequence.
sub set_sequence {
    my ($self, $seq, $value) = @_;
    croak("?INTERNAL ERROR: set sequence while not connected") unless $dbh;

    # Init a sequence to value.
    # The next call to get_sequence will return this value.
    $dbh->do("SELECT setval('$seq', $value, false)");
    $value;
}

################ Attachments ################

use Digest::MD5 ();
use MIME::Base64 ();
use POSIX qw(O_RDONLY);
use File::Temp ();
use File::Basename ();

sub get_attachment {
    my ( $self, $id ) = @_;

    my $rr = $dbh->selectrow_arrayref("SELECT att_name,att_encoding,att_content".
				      " FROM Attachments".
				      " WHERE att_id = ?", {}, $id );
    my ( $name, $enc, $data ) = @{ $rr };
    $data = MIME::Base64::decode_base64($data) if $enc == ATTENCODING_BASE64;

    my $tmp = File::Temp->new( UNLINK => 0,
			       SUFFIX => "__$name" );
    syswrite( $tmp, $data, length($data) );
    $tmp->close;
    return $tmp->filename;
}

sub store_attachment {
    my ( $self, $filename ) = @_;

    sysopen( my $fd, $filename, O_RDONLY )
      or die(__x("Bijlage {file} kan niet worden opgeslagen: {err}",
		 file => $filename, err => "".$!)."\n");

    my $cnt;
    my $buf = "";
    my $offset = 0;
#    my $ctx = Digest::MD5->new;
    while ( ( $cnt = sysread( $fd, $buf, 20480, $offset ) ) > 0 ) {

=begin later

	unless ( defined $type ) {
	    if ( $buf =~ /^\%PDF-/ ) {
		$type = ATTTYPE_PDF;
	    }
	    elsif ( $buf =~ /^\x89PNG\x0d\x0a\x1a\x0a/ ) {
		$type = ATTTYPE_PNG;
	    }
	    elsif ( $buf =~ /^\xff\xd8/ ) {
		$type = ATTTYPE_JPG;
	    }
	    elsif ( $buf =~ /^[[:print:]\s]*$/ ) {
		$type = ATTTYPE_TEXT;
	    }
	    else {
		die(__x("Bijlage {file} is van een niet-ondersteund type",
			file => $filename)."\n");
	    }
	}

=cut

	$offset += $cnt;
    }
    die(__x("Bijlage {file} kon niet worden gelezen: {err}",
	    file => $filename), err => !$)."\n") unless $cnt == 0;
    close($fd);

#    $ctx->add($buf);
#    my $checksum = $ctx->hexdigest;
    my $name = File::Basename::fileparse($filename);
    my $att_id = $self->get_sequence("attachments_id_seq");
    my @fields = qw( id name size encoding content );
    $dbh->do("INSERT INTO Attachments" .
	     " (" . join(",", map { +"att_$_" } @fields ) . ") ".
	     " VALUES (" . join(",", ("?") x @fields) . ")", {},
	     $att_id, $name, $offset, ATTENCODING_BASE64,
	     MIME::Base64::encode($buf, "") );
    return $att_id;

}

sub drop_attachment {
    my ( $self, $id ) = @_;
    $dbh->do("DELETE FROM Attachments WHERE att_id = ?", {}, $id );
}

################ Interactive SQL ################

# API: Interactive SQL.
sub isql {
    my ($self, @args) = @_;

    my $dbname = $cfg->val(qw(database fullname));
    my $cmd = "psql";
    my @cmd = ( $cmd );

    for ( $cfg->val("database", "user", undef) ) {
	next unless $_;
	push(@cmd, "-U", $_);
    }
    for ( $cfg->val("database", "host", undef) ) {
	next unless $_;
	push(@cmd, "-h", $_);
    }
    for ( $cfg->val("database", "port", undef) ) {
	next unless $_;
	push(@cmd, "-p", $_);
    }
    push(@cmd, "-d", $dbname);

    if ( @args ) {
	push(@cmd, "-c", "@args");
    }

    my $res = system { $cmd } @cmd;
    # warn(sprintf("=> ret = %02x", $res)."\n") if $res;

}

################ PostgreSQL Compatibility ################

# API: feature  Can we?
sub feature {
    my $self = shift;
    my $feat = lc(shift);

    # Known features:
    #
    # pgcopy	F PostgreSQL fast input copying
    # prepcache T Statement handles may be cached
    # filter    C SQL filter routine
    #
    # Unknown/unsupported features may be ignored.

    if ( $feat eq "pgcopy" ) {
	return 1 if ($DBD::Pg::VERSION||"0") ge "1.41";
	warn("%"."Not using PostgreSQL fast load. DBD::Pg::VERSION = ",
	     ($DBD::Pg::VERSION||"0"), ", needs 1.41 or later\n");
	return;
    }

    return 1 if $feat eq "prepcache";

    return 1 if $feat eq "import";

    return 1 if $feat eq "test";

    # Return false for all others.
    return;
}

################ End PostgreSQL Compatibility ################

1;
