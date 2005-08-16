# generated by wxGlade 0.4cvs on Wed Aug  3 22:50:32 2005
# To get wxPerl visit http://wxPerl.sourceforge.net/

use Wx 0.15 qw[:allclasses];
use strict;

package main;

our $config;
our $app;
our $dbh;

package RepBalRes;

use Wx qw[:everything];
use base qw(Wx::Dialog);
use strict;

# begin wxGlade: ::dependencies
# end wxGlade

sub new {
	my( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

# begin wxGlade: RepBalRes::new

	$style = wxDEFAULT_DIALOG_STYLE|wxRESIZE_BORDER|wxTHICK_FRAME 
		unless defined $style;

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
	$self->{b_refresh} = Wx::Button->new($self, wxID_REFRESH, "");
	$self->{b_props} = Wx::Button->new($self, wxID_PREFERENCES, "");
	$self->{l_detail} = Wx::StaticText->new($self, -1, "Detail:", wxDefaultPosition, wxDefaultSize, );
	$self->{bd_less} = Wx::BitmapButton->new($self, -1, Wx::Bitmap->new("edit_remove.png", wxBITMAP_TYPE_ANY));
	$self->{bd_more} = Wx::BitmapButton->new($self, -1, Wx::Bitmap->new("edit_add.png", wxBITMAP_TYPE_ANY));
	$self->{b_close} = Wx::Button->new($self, wxID_CLOSE, "");
	$self->{gr_report} = Wx::Grid->new($self, -1);

	$self->__set_properties();
	$self->__do_layout();

	Wx::Event::EVT_BUTTON($self, wxID_REFRESH, \&OnRefresh);
	Wx::Event::EVT_BUTTON($self, wxID_PREFERENCES, \&OnProps);
	Wx::Event::EVT_BUTTON($self, $self->{bd_less}->GetId, \&OnLess);
	Wx::Event::EVT_BUTTON($self, $self->{bd_more}->GetId, \&OnMore);
	Wx::Event::EVT_BUTTON($self, wxID_CLOSE, \&OnClose);

# end wxGlade
	return $self;

}

sub init {
    my ($self, $me) = @_;
    $self->{mew} = "r${me}w";
    $self->SetTitle($me eq "bal" ? "Balans" : 
		    $me eq "prf" ? "Proef- en Saldibalans" : "Resultaatrekening");
    $self->{detail} = 2;
    $self->{bd_more}->Enable(0);
    $self->{bd_less}->Enable(1);
    $self->refresh;
}

sub refresh {
    my ($self) = @_;
    require Report;
    my $gr = $self->{gr_report};
    $gr->SetRowLabelSize(0);
    $gr->SetColLabelSize(22);
    $gr->EnableEditing(0);
    $gr->EnableDragRowSize(0);
    $gr->SetSelectionMode(wxGridSelectRows);

    if ( $self->{mew} eq "rprfw" ) {
	$gr->CreateGrid(0, 6);
	require EB::Report::Proof;
	EB::Report::Proof->new->perform
	    ({ reporter => Report->new( grid => $gr, saldi => 1,
					detail => $self->{detail} ),
	       detail => $self->{detail} });
    }
    else {
	$gr->CreateGrid(0, 4);
	require EB::Report::Balres;
	my $fun = $self->{mew} eq "rbalw" ? "balans" : "result";
	EB::Report::Balres->new->$fun
	    ({ reporter => Report->new( grid => $gr,
					detail => $self->{detail} ),
	       detail => $self->{detail} });
    }
}

sub __set_properties {
	my $self = shift;

# begin wxGlade: RepBalRes::__set_properties

	$self->SetTitle("Balans/Resultaat");
	$self->{b_refresh}->SetToolTipString("Bijwerken naar laatste gegevens");
	$self->{b_props}->SetToolTipString("Instellingsgegevens");
	$self->{bd_less}->SetToolTipString("Minder uitgebreid");
	$self->{bd_less}->SetSize($self->{bd_less}->GetBestSize());
	$self->{bd_more}->SetToolTipString("Meer uitgebreid");
	$self->{bd_more}->SetSize($self->{bd_more}->GetBestSize());
	$self->{b_close}->SetToolTipString("Venster sluiten");

# end wxGlade
}

sub __do_layout {
	my $self = shift;

# begin wxGlade: RepBalRes::__do_layout

	$self->{sizer_1} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_2} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_3} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_3}->Add($self->{b_refresh}, 0, wxLEFT|wxTOP|wxEXPAND|wxADJUST_MINSIZE, 5);
	$self->{sizer_3}->Add($self->{b_props}, 0, wxLEFT|wxTOP|wxEXPAND|wxADJUST_MINSIZE, 5);
	$self->{sizer_3}->Add(5, 1, 1, wxADJUST_MINSIZE, 0);
	$self->{sizer_3}->Add($self->{l_detail}, 0, wxLEFT|wxTOP|wxALIGN_CENTER_VERTICAL|wxADJUST_MINSIZE, 5);
	$self->{sizer_3}->Add($self->{bd_less}, 0, wxTOP|wxEXPAND|wxALIGN_CENTER_VERTICAL|wxADJUST_MINSIZE, 5);
	$self->{sizer_3}->Add($self->{bd_more}, 0, wxTOP|wxEXPAND|wxADJUST_MINSIZE, 5);
	$self->{sizer_3}->Add(5, 1, 1, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{sizer_3}->Add($self->{b_close}, 0, wxRIGHT|wxTOP|wxEXPAND|wxADJUST_MINSIZE, 5);
	$self->{sizer_2}->Add($self->{sizer_3}, 0, wxEXPAND, 0);
	$self->{sizer_2}->Add($self->{gr_report}, 1, wxALL|wxEXPAND, 5);
	$self->{sizer_1}->Add($self->{sizer_2}, 1, wxEXPAND, 5);
	$self->SetAutoLayout(1);
	$self->SetSizer($self->{sizer_1});
	$self->{sizer_1}->Fit($self);
	$self->{sizer_1}->SetSizeHints($self);
	$self->Layout();

# end wxGlade
}


# wxGlade: RepBalRes::OnRefresh <event_handler>
sub OnRefresh {
    my ($self, $event) = @_;
    $self->refresh;
}

# wxGlade: RepBalRes::OnProps <event_handler>
sub OnProps {
    my ($self, $event) = @_;
    $event->Skip;
}

# wxGlade: RepBalRes::OnMore <event_handler>
sub OnMore {
    my ($self, $event) = @_;
    if ( $self->{detail} < 2 ) {
	$self->{detail}++;
	$self->refresh;
    }
    $self->{bd_more}->Enable($self->{detail} < 2);
    $self->{bd_less}->Enable($self->{detail} >= 0);
}

# wxGlade: RepBalRes::OnLess <event_handler>
sub OnLess {
    my ($self, $event) = @_;
    if ( $self->{detail} >= 0 ) {
	$self->{detail}--;
	$self->refresh;
    }
    $self->{bd_more}->Enable($self->{detail} < 2);
    $self->{bd_less}->Enable($self->{detail} >= 0);
}

# wxGlade: RepBalRes::OnClose <event_handler>
sub OnClose {
    my ($self, $event) = @_;
    @{$config->get($self->{mew})}{qw(xpos ypos xwidth ywidth)} = ($self->GetPositionXY, $self->GetSizeWH);
    $self->Show(0);
}

# end of class RepBalRes

1;

