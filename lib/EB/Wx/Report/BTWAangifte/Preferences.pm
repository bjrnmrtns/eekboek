# generated by wxGlade 0.4*** on Tue Sep 13 17:30:45 2005
# To get wxPerl visit http://wxPerl.sourceforge.net/

use Wx 0.15 qw[:allclasses];
use strict;
package BtwPrefsDialog;

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

# begin wxGlade: BtwPrefsDialog::new

	$style = wxDEFAULT_DIALOG_STYLE|wxRESIZE_BORDER|wxTHICK_FRAME 
		unless defined $style;

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
	$self->{sz_prefs_staticbox} = Wx::StaticBox->new($self, -1, _T("Voorkeuren") );
	$self->{sz_periode_staticbox} = Wx::StaticBox->new($self, -1, _T("Periode") );
	$self->{b_jaar} = Wx::ToggleButton->new($self, -1, _T("Jaar"));
	$self->{b_kw1} = Wx::ToggleButton->new($self, -1, _T("Kwart 1"));
	$self->{b_m1} = Wx::ToggleButton->new($self, -1, _T("Jan"));
	$self->{b_m2} = Wx::ToggleButton->new($self, -1, _T("Feb"));
	$self->{b_m3} = Wx::ToggleButton->new($self, -1, _T("Mar"));
	$self->{b_kw2} = Wx::ToggleButton->new($self, -1, _T("Kwart 2"));
	$self->{b_m4} = Wx::ToggleButton->new($self, -1, _T("Apr"));
	$self->{b_m5} = Wx::ToggleButton->new($self, -1, _T("Mei"));
	$self->{b_m6} = Wx::ToggleButton->new($self, -1, _T("Jun"));
	$self->{b_kw3} = Wx::ToggleButton->new($self, -1, _T("Kwart 3"));
	$self->{b_m7} = Wx::ToggleButton->new($self, -1, _T("Jul"));
	$self->{b_m8} = Wx::ToggleButton->new($self, -1, _T("Aug"));
	$self->{b_m9} = Wx::ToggleButton->new($self, -1, _T("Sep"));
	$self->{b_kw4} = Wx::ToggleButton->new($self, -1, _T("Kwart 4"));
	$self->{b_m10} = Wx::ToggleButton->new($self, -1, _T("Okt"));
	$self->{b_m11} = Wx::ToggleButton->new($self, -1, _T("Nov"));
	$self->{b_m12} = Wx::ToggleButton->new($self, -1, _T("Dec"));
	$self->{l_default} = Wx::StaticText->new($self, -1, _T("Standaardinstelling"), wxDefaultPosition, wxDefaultSize, );
	$self->{b_ok} = Wx::Button->new($self, wxID_OK, _T("OK"));
	$self->{b_cancel} = Wx::Button->new($self, wxID_CANCEL, _T("Cancel"));

	$self->__set_properties();
	$self->__do_layout();

	Wx::Event::EVT_BUTTON($self, wxID_OK, \&OnOk);
	Wx::Event::EVT_BUTTON($self, wxID_CANCEL, \&OnCancel);

# end wxGlade

	$self->{b_jaar}->SetLabel("Gehele jaar ".$parent->{year});
	my $t = $parent->{btwp} == 1 ? "jaar" :
	  $parent->{btwp} == 4 ? "kwartaal" :
	    $parent->{btwp} == 12 ? "maand" : $parent->{btwp};
	$self->{l_default}->SetLabel("Standaardinstelling: per $t");

	Wx::Event::EVT_TOGGLEBUTTON($self, $self->{b_jaar}->GetId,
				    sub { $self->{b_jaar}->SetValue(1);
					  for my $kw ( 1..4 ) {
					       $self->{"b_kw$kw"}->SetValue(0);
					  }
					  for my $m ( 1..12 ) {
					      $self->{"b_m$m"}->SetValue(1);
					  }
					  $self->{periode} = "j";
				      });

	foreach my $kw ( 1 .. 4 ) {
	    Wx::Event::EVT_TOGGLEBUTTON($self, $self->{"b_kw$kw"}->GetId,
					sub { $self->{b_jaar}->SetValue(0);
					      for my $k ( 1..4 ) {
						  $self->{"b_kw$k"}->SetValue($k == $kw);
					      }
					      for my $m ( 1..12 ) {
						  $self->{"b_m$m"}->SetValue($m > ($kw-1)*3 && $m <= $kw*3);
					      }
					      $self->{periode} = "k$kw";
					  });
	}
	foreach my $mm ( 1 .. 12 ) {
	    Wx::Event::EVT_TOGGLEBUTTON($self, $self->{"b_m$mm"}->GetId,
					sub { $self->{b_jaar}->SetValue(0);
					      for my $k ( 1..4 ) {
						  $self->{"b_kw$k"}->SetValue(0);
					      }
					      for my $m ( 1..12 ) {
						  $self->{"b_m$m"}->SetValue($m == $mm);
					      }
					      $self->{periode} = "m$mm";
					  });
	}

	return $self;

}


sub __set_properties {
	my $self = shift;

# begin wxGlade: BtwPrefsDialog::__set_properties

	$self->SetTitle(_T("dialog_1"));
	$self->{b_jaar}->SetToolTipString(_T("Gehele jaar"));
	$self->{b_kw1}->SetToolTipString(_T("Eerste kwartaal"));
	$self->{b_m1}->SetToolTipString(_T("Januari"));
	$self->{b_m2}->SetToolTipString(_T("Februari"));
	$self->{b_m3}->SetToolTipString(_T("Maart"));
	$self->{b_kw2}->SetToolTipString(_T("Tweede kwartaal"));
	$self->{b_m4}->SetToolTipString(_T("April"));
	$self->{b_m5}->SetToolTipString(_T("Mei"));
	$self->{b_m6}->SetToolTipString(_T("Juni"));
	$self->{b_kw3}->SetToolTipString(_T("Derde kwartaal"));
	$self->{b_m7}->SetToolTipString(_T("Juli"));
	$self->{b_m8}->SetToolTipString(_T("Augustus"));
	$self->{b_m9}->SetToolTipString(_T("September"));
	$self->{b_kw4}->SetToolTipString(_T("Vierde kwartaal"));
	$self->{b_m10}->SetToolTipString(_T("Oktober"));
	$self->{b_m11}->SetToolTipString(_T("November"));
	$self->{b_m12}->SetToolTipString(_T("December"));
	$self->{b_ok}->SetDefault();

# end wxGlade
}

sub __do_layout {
	my $self = shift;

# begin wxGlade: BtwPrefsDialog::__do_layout

	$self->{sz_outer} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sz_prefs}= Wx::StaticBoxSizer->new($self->{sz_prefs_staticbox}, wxVERTICAL);
	$self->{sz_buttons} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sz_periode}= Wx::StaticBoxSizer->new($self->{sz_periode_staticbox}, wxVERTICAL);
	$self->{gr_m} = Wx::FlexGridSizer->new(4, 4, 0, 0);
	$self->{sz_periode}->Add($self->{b_jaar}, 0, wxLEFT|wxRIGHT|wxTOP|wxEXPAND|wxADJUST_MINSIZE, 5);
	$self->{gr_m}->Add($self->{b_kw1}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m1}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m2}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m3}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_kw2}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m4}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m5}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m6}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_kw3}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m7}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m8}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m9}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_kw4}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m10}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m11}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->Add($self->{b_m12}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{gr_m}->AddGrowableCol(0);
	$self->{gr_m}->AddGrowableCol(1);
	$self->{gr_m}->AddGrowableCol(2);
	$self->{gr_m}->AddGrowableCol(3);
	$self->{sz_periode}->Add($self->{gr_m}, 0, wxLEFT|wxRIGHT|wxBOTTOM|wxEXPAND, 5);
	$self->{sz_periode}->Add($self->{l_default}, 0, wxALL|wxEXPAND|wxADJUST_MINSIZE, 5);
	$self->{sz_prefs}->Add($self->{sz_periode}, 0, wxALL|wxEXPAND, 5);
	$self->{sz_prefs}->Add(1, 5, 1, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{sz_buttons}->Add($self->{b_ok}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{sz_buttons}->Add(5, 1, 1, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{sz_buttons}->Add($self->{b_cancel}, 0, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{sz_prefs}->Add($self->{sz_buttons}, 0, wxLEFT|wxRIGHT|wxBOTTOM|wxEXPAND, 5);
	$self->{sz_outer}->Add($self->{sz_prefs}, 1, wxALL|wxEXPAND, 5);
	$self->SetAutoLayout(1);
	$self->SetSizer($self->{sz_outer});
	$self->{sz_outer}->Fit($self);
	$self->{sz_outer}->SetSizeHints($self);
	$self->Layout();

# end wxGlade
}

# wxGlade: BtwPrefsDialog::OnOk <event_handler>
sub OnOk {
    my ($self, $event) = @_;
    $event->Skip;
}

# wxGlade: BtwPrefsDialog::OnCancel <event_handler>
sub OnCancel {
    my ($self, $event) = @_;
    $self->EndModal(-1);
}

# end of class BtwPrefsDialog

1;

