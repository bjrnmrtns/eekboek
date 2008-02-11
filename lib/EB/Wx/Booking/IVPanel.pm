#! perl

# $Id: IVPanel.pm,v 1.6 2008/02/11 15:05:42 jv Exp $

package main;

our $state;
our $dbh;
our $app;

use strict;

package EB::Wx::Booking::IVPanel;

use EB;
use EB::Format;

use Wx qw[:everything];
use base qw(Wx::Dialog);
use strict;

# begin wxGlade: ::dependencies
use Wx::Grid;
# end wxGlade

sub new {
	my( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

# begin wxGlade: EB::Wx::Booking::IVPanel::new

	$style = wxDEFAULT_DIALOG_STYLE|wxRESIZE_BORDER|wxTHICK_FRAME 
		unless defined $style;

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
	$self->{gr_main} = Wx::Grid->new($self, -1);
	$self->{b_close} = Wx::Button->new($self, wxID_CLOSE, "");

	$self->__set_properties();
	$self->__do_layout();

	Wx::Event::EVT_BUTTON($self, $self->{b_close}->GetId, \&OnClose);

# end wxGlade

	Wx::Event::EVT_GRID_CELL_LEFT_DCLICK($self->{gr_main}, \&OnDClick);

	$self->{mew} = "ivw";
	$self->SetTitle($title);
	return $self;

}


sub __set_properties {
	my $self = shift;

# begin wxGlade: EB::Wx::Booking::IVPanel::__set_properties

	$self->SetTitle(_T("Inkoop/Verkoop Boeking"));
	$self->SetSize($self->ConvertDialogSizeToPixels(Wx::Size->new(300, 168)));
	$self->{gr_main}->CreateGrid(0, 6);
	$self->{gr_main}->SetRowLabelSize(0);
	$self->{gr_main}->SetColLabelSize(22);
	$self->{gr_main}->EnableEditing(0);
	$self->{gr_main}->EnableDragRowSize(0);
	$self->{gr_main}->SetSelectionMode(wxGridSelectRows);
	$self->{gr_main}->SetColLabelValue(0, _T("Nr"));
	$self->{gr_main}->SetColLabelValue(1, _T("Datum"));
	$self->{gr_main}->SetColLabelValue(2, _T("Relatie"));
	$self->{gr_main}->SetColLabelValue(3, _T("Omschrijving"));
	$self->{gr_main}->SetColLabelValue(4, _T("Bedrag"));
	$self->{gr_main}->SetColLabelValue(5, _T("Voldaan"));
	$self->{b_close}->SetFocus();

# end wxGlade
}

sub __do_layout {
	my $self = shift;

# begin wxGlade: EB::Wx::Booking::IVPanel::__do_layout

	$self->{sz_outer} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sz_main} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sz_buttons} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sz_main}->Add($self->{gr_main}, 1, wxEXPAND, 0);
	$self->{sz_buttons}->Add(5, 1, 1, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{sz_buttons}->Add($self->{b_close}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{sz_main}->Add($self->{sz_buttons}, 0, wxTOP|wxEXPAND, 5);
	$self->{sz_outer}->Add($self->{sz_main}, 1, wxALL|wxEXPAND, 5);
	$self->SetSizer($self->{sz_outer});
	$self->Layout();

# end wxGlade
}

sub init {
    my ($self, $id, $desc, $type) = @_;
    $self->SetTitle(__x("Dagboek: {dbk}", dbk => $desc));
    $self->{dbk_id} = $id;
    $self->{dbk_desc} = $desc;
    $self->{dbk_type} = $type;
    $self->refresh;
}

sub refresh {
    my ($self) = @_;

    my $sth = $dbh->sql_exec("SELECT bsk_id, bsk_nr, bsk_desc,".
			     " bsk_date, bsk_amount, bsk_open, bsr_rel_code".
			     " From Boekstukken, Boekstukregels".
			     " WHERE bsk_dbk_id = ?".
			     " AND bsr_bsk_id = bsk_id AND bsr_nr = 1".
			     " ORDER BY bsk_date, bsk_id",
			     $self->{dbk_id});

    my $gr = $self->{gr_main};
    $gr->DeleteRows(0, $gr->GetNumberRows);

    my $row = 0;
    while ( my $rr = $sth->fetchrow_arrayref ) {
	my ($bsk_id, $bsk_nr, $bsk_desc, $bsk_date, $bsk_amount, $bsk_open, $bsr_rel) = @$rr;
	$bsk_nr =~ s/\s+$//;
	$bsr_rel =~ s/\s+$//;
	$bsk_amount = -$bsk_amount if $self->{dbk_type} == DBKTYPE_INKOOP;

	my $col = 0;
	$gr->AppendRows(1);
	$gr->SetCellValue($row, $col, $bsk_nr);
	$gr->SetCellAlignment($row, $col, wxALIGN_RIGHT, wxALIGN_CENTER);
	$col++;
	$gr->SetCellValue($row, $col, $bsk_date);
	$gr->SetCellAlignment($row, $col, wxALIGN_LEFT, wxALIGN_CENTER);
	$col++;
	$gr->SetCellValue($row, $col, $bsr_rel);
	$gr->SetCellAlignment($row, $col, wxALIGN_LEFT, wxALIGN_CENTER);
	$col++;
	$gr->SetCellValue($row, $col, $bsk_desc);
	$gr->SetCellAlignment($row, $col, wxALIGN_LEFT, wxALIGN_CENTER);
	$col++;
	$gr->SetCellValue($row, $col, numfmt($bsk_amount));
	$gr->SetCellAlignment($row, $col, wxALIGN_RIGHT, wxALIGN_CENTER);
	$col++;
	$gr->SetCellValue($row, $col, $bsk_open ? _T("Nee") : _T("Ja"));
	$gr->SetCellAlignment($row, $col, wxALIGN_CENTER, wxALIGN_CENTER);
	$row++;
    }

    $self->resize;
}

sub resize {
    my ($self) = @_;
    my $gr = $self->{gr_main};

    # Calculate minimal fit.
    $gr->AutoSizeColumns(1);

    # Get the total minimal width.
    my $w = 0;
    my @w;
    my $cols = $gr->GetNumberCols;
    for ( 0 .. $cols-1 ) {
	push(@w, $gr->GetColSize($_));
	$w += $w[-1];
    }

    # Get available width.
    my $width;
    if ( $gr->can("GetVirtualSizeWH") ) {
	$width = ($gr->GetVirtualSizeWH)[0];
    }
    else {
	# Assume scrollbar.
	$width = ($gr->GetSizeWH)[0] - 16;
    }

    # Scale columns if possible.
    if ( $w < $width ) {
	my $r = $width / $w;
	for ( 0 .. $cols-1 ) {
	    $gr->SetColSize($_, int($r*$w[$_]));
	}
    }
}

# wxGlade: EB::Wx::Booking::IVPanel::OnClose <event_handler>
sub OnClose {
    my ($self, $event) = @_;
    # Remember position and size.
    @{$state->get($self->{mew})}{qw(xpos ypos xwidth ywidth)} = ($self->GetPositionXY, $self->GetSizeWH);
    # Disappear.
    $self->Show(0);
}

# wxGlade: EB::Wx::Booking::IVPanel::OnDClick <event_handler>
sub OnDClick {
    my ($self, $event) = @_;
    my $row = $event->GetRow;
    warn("row = $row\n");
}

# end of class EB::Wx::Booking::IVPanel

1;
