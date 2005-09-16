# generated by wxGlade 0.4cvs on Mon Aug  1 17:59:21 2005
# To get wxPerl visit http://wxPerl.sourceforge.net/

package main;

our $config;
our $dbh;

use Wx 0.15 qw[:allclasses];
use strict;
package MainFrame;

use Wx qw[:everything];
use base qw(Wx::Frame);
use strict;

# begin wxGlade: ::dependencies
# end wxGlade

my %cmds;

sub new {
	my( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

# begin wxGlade: MainFrame::new

	$style = wxDEFAULT_FRAME_STYLE 
		unless defined $style;

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
	

	# Menu Bar

	$self->{mainframe_menubar} = Wx::MenuBar->new();
	$self->SetMenuBar($self->{mainframe_menubar});
	use constant MENU_NEW => Wx::NewId();
	use constant MENU_PREFS => Wx::NewId();
	use constant MENU_LOGW => Wx::NewId();
	use constant MENU_LOGCLEAN => Wx::NewId();
	use constant MENU_RESTART => Wx::NewId();
	use constant MENU_GBK => Wx::NewId();
	use constant MENU_REL => Wx::NewId();
	use constant MENU_BTW => Wx::NewId();
	use constant MENU_STD => Wx::NewId();
	use constant MENU_R_PRF => Wx::NewId();
	use constant MENU_R_BAL => Wx::NewId();
	use constant MENU_R_RES => Wx::NewId();
	use constant MENU_R_GBK => Wx::NewId();
	use constant MENU_R_JNL => Wx::NewId();
	use constant MENU_R_BTW => Wx::NewId();
	use constant MENU_R_DEB => Wx::NewId();
	use constant MENU_R_CRD => Wx::NewId();
	my $wxglade_tmp_menu;
	$wxglade_tmp_menu = Wx::Menu->new();
	$wxglade_tmp_menu->Append(wxID_NEW, _T("Nieuw ..."), _T("Aanmaken nieuwe administartie"));
	$wxglade_tmp_menu->Append(MENU_NEW, _T("Nieuw (Wizard) ..."), _T("Test wizard"));
	$wxglade_tmp_menu->Append(wxID_OPEN, _T("Open ..."), _T("Open een bestaande administratie"));
	$wxglade_tmp_menu->Append(wxID_CLOSE, _T("Sluiten"), _T("Be�indig het werken met deze administratie"));
	$wxglade_tmp_menu->AppendSeparator();
	$wxglade_tmp_menu->Append(MENU_PREFS, _T("Instellingen"), _T("Instellingen"));
	$wxglade_tmp_menu->AppendSeparator();
	$wxglade_tmp_menu->Append(MENU_LOGW, _T("Verberg log venster"), _T("Toon of verberg het log venster"));
	$wxglade_tmp_menu->Append(MENU_LOGCLEAN, _T("Log venster schoonmaken"), "");
	$wxglade_tmp_menu->AppendSeparator();
	$wxglade_tmp_menu->Append(MENU_RESTART, _T("Opnieuw starten\tAlt-R"), _T("Herstart (voor testen)"));
	$wxglade_tmp_menu->Append(wxID_EXIT, _T("Be�ndigen\tAlt-x"), _T("Be�indig het programma"));
	$self->{mainframe_menubar}->Append($wxglade_tmp_menu, _T("&Bestand"));
	$wxglade_tmp_menu = Wx::Menu->new();
	$wxglade_tmp_menu->Append(wxID_CUT, _T("Knip"), "");
	$wxglade_tmp_menu->Append(wxID_PASTE, _T("Plak"), "");
	$wxglade_tmp_menu->Append(wxID_COPY, _T("Kopi�er"), "");
	$self->{mainframe_menubar}->Append($wxglade_tmp_menu, _T("&Edit"));
	$wxglade_tmp_menu = Wx::Menu->new();
	$wxglade_tmp_menu->Append(MENU_GBK, _T("Grootboekrekeningen"), _T("Onderhoud rekeningschema en grootboekrekeningen"));
	$wxglade_tmp_menu->Append(MENU_REL, _T("Relaties"), _T("Onderhoud debiteuren en crediteuren"));
	$wxglade_tmp_menu->Append(MENU_BTW, _T("BTW Tarieven"), _T("Onderhoud BTW tarieven"));
	$wxglade_tmp_menu->Append(MENU_STD, _T("Koppelingen"), _T("Onderhoud Standaardrekeningen (koppelingen)"));
	$self->{mainframe_menubar}->Append($wxglade_tmp_menu, _T("&Onderhoud"));
	$wxglade_tmp_menu = Wx::Menu->new();
	$self->{mainframe_menubar}->Append($wxglade_tmp_menu, _T("&Dagboeken"));
	$wxglade_tmp_menu = Wx::Menu->new();
	$wxglade_tmp_menu->Append(MENU_R_PRF, _T("Proef- en Saldibalans"), _T("Opmaken Proef- en Saldibalans"));
	$wxglade_tmp_menu->Append(MENU_R_BAL, _T("Balans"), _T("Opmaken Balans"));
	$wxglade_tmp_menu->Append(MENU_R_RES, _T("Resultaatrekening"), _T("Opmaken Resultaatrekening"));
	$wxglade_tmp_menu->AppendSeparator();
	$wxglade_tmp_menu->Append(MENU_R_GBK, _T("Grootboek"), _T("Opmaken Grootboekrapportage"));
	$wxglade_tmp_menu->Append(MENU_R_JNL, _T("Journaal"), _T("Opmaken Journaal"));
	$wxglade_tmp_menu->Append(MENU_R_BTW, _T("BTW aangifte"), _T("Opmaken BTW aangifte"));
	$wxglade_tmp_menu->AppendSeparator();
	$wxglade_tmp_menu->Append(MENU_R_DEB, _T("Debiteuren"), _T("Opmaken Debiteurenoverzicht"));
	$wxglade_tmp_menu->Append(MENU_R_CRD, _T("Crediteuren"), _T("Opmaken Crediteurenoverzicht"));
	$self->{mainframe_menubar}->Append($wxglade_tmp_menu, _T("Rapportages"));
	$wxglade_tmp_menu = Wx::Menu->new();
	$wxglade_tmp_menu->Append(wxID_ABOUT, _T("&Info"), _T("Informatie"));
	$self->{mainframe_menubar}->Append($wxglade_tmp_menu, _T("&Hulp"));
	
# Menu Bar end

	$self->{mainframe_statusbar} = $self->CreateStatusBar(1, 0);
	$self->{eb_logo} = Wx::StaticBitmap->new($self, -1, Wx::Bitmap->new("/home/jv/src/eekboek/GUI/eb.jpg", wxBITMAP_TYPE_ANY), wxDefaultPosition, wxDefaultSize, wxDOUBLE_BORDER);
	$self->{bitmap_1} = Wx::StaticBitmap->new($self, -1, Wx::Bitmap->new("/home/jv/src/eekboek/GUI/perl_powered.png", wxBITMAP_TYPE_ANY), wxDefaultPosition, wxDefaultSize, );
	$self->{tx_log} = Wx::TextCtrl->new($self, -1, "", wxDefaultPosition, wxDefaultSize, wxTE_MULTILINE|wxTE_READONLY|wxHSCROLL);

	$self->__set_properties();
	$self->__do_layout();

	Wx::Event::EVT_MENU($self, wxID_NEW, \&OnNew);
	Wx::Event::EVT_MENU($self, MENU_NEW, \&OnNewWiz);
	Wx::Event::EVT_MENU($self, wxID_OPEN, \&OnOpen);
	Wx::Event::EVT_MENU($self, wxID_CLOSE, \&OnClose);
	Wx::Event::EVT_MENU($self, MENU_PREFS, \&OnPreferences);
	Wx::Event::EVT_MENU($self, MENU_LOGW, \&OnLogw);
	Wx::Event::EVT_MENU($self, MENU_LOGCLEAN, \&OnLogClean);
	Wx::Event::EVT_MENU($self, MENU_RESTART, \&OnRestart);
	Wx::Event::EVT_MENU($self, wxID_EXIT, \&OnExit);
	Wx::Event::EVT_MENU($self, MENU_GBK, \&OnMGbk);
	Wx::Event::EVT_MENU($self, MENU_REL, \&OnMRel);
	Wx::Event::EVT_MENU($self, MENU_BTW, \&OnMBtw);
	Wx::Event::EVT_MENU($self, MENU_STD, \&OnMStdAcc);
	Wx::Event::EVT_MENU($self, MENU_R_PRF, \&OnRPrf);
	Wx::Event::EVT_MENU($self, MENU_R_BAL, \&OnRBal);
	Wx::Event::EVT_MENU($self, MENU_R_RES, \&OnRRes);
	Wx::Event::EVT_MENU($self, MENU_R_GBK, \&OnRGbk);
	Wx::Event::EVT_MENU($self, MENU_R_JNL, \&OnRJnl);
	Wx::Event::EVT_MENU($self, MENU_R_BTW, \&OnRBtw);
	Wx::Event::EVT_MENU($self, MENU_R_DEB, \&OnRDeb);
	Wx::Event::EVT_MENU($self, MENU_R_CRD, \&OnRCrd);
	Wx::Event::EVT_MENU($self, wxID_ABOUT, \&OnAbout);

# end wxGlade

	$self->{OLDLOG} = Wx::Log::SetActiveTarget (Wx::LogTextCtrl->new($self->{tx_log}));
	Wx::Log::SetTimestamp("%T");
	Wx::LogMessage("Administratie: " . $config->lastdb);

	$self->dagboekenmenu;

	use Wx::Event qw(EVT_CLOSE);

	EVT_CLOSE($self, \&OnExit);

	%cmds = ( open	 => wxID_OPEN,
		  new    => wxID_NEW,
		  wiz    => MENU_NEW,
		  gbk	 => MENU_GBK,
		  rel	 => MENU_REL,
		  btw	 => MENU_BTW,
		  std	 => MENU_STD,
		  rbal	 => MENU_R_BAL,
		  rres	 => MENU_R_RES,
		  rprf	 => MENU_R_PRF,
		  rgbk	 => MENU_R_GBK,
		  jnl	 => MENU_R_JNL,
		  rbtw	 => MENU_R_BTW,
		  rdeb	 => MENU_R_DEB,
		  rcrd	 => MENU_R_CRD,
		  log	 => MENU_LOGW,
		  about	 => wxID_ABOUT,
	     );

	$self;
}

sub __set_properties {
	my $self = shift;

# begin wxGlade: MainFrame::__set_properties

	$self->SetTitle(_T("EekBoek"));
	$self->SetBackgroundColour(Wx::Colour->new(255, 255, 255));
	$self->{mainframe_statusbar}->SetStatusWidths(-1);
	
	my( @mainframe_statusbar_fields ) = (
		_T("EekBoek � 2005 Squirrel Consultancy � Geen administratie geladen")
	);

	if( @mainframe_statusbar_fields ) {
		$self->{mainframe_statusbar}->SetStatusText($mainframe_statusbar_fields[$_], $_) 	
		for 0 .. $#mainframe_statusbar_fields ;
	}

# end wxGlade
}

sub __do_layout {
	my $self = shift;

# begin wxGlade: MainFrame::__do_layout

	$self->{sz_main} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_4} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_4}->Add(150, 20, 1, wxADJUST_MINSIZE, 0);
	$self->{sizer_4}->Add($self->{eb_logo}, 0, wxALL|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL|wxADJUST_MINSIZE, 40);
	$self->{sizer_4}->Add($self->{bitmap_1}, 0, wxRIGHT|wxTOP|wxBOTTOM|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL|wxADJUST_MINSIZE, 40);
	$self->{sizer_4}->Add(150, 20, 1, wxADJUST_MINSIZE, 0);
	$self->{sz_main}->Add($self->{sizer_4}, 1, wxEXPAND, 0);
	$self->{sz_main}->Add($self->{tx_log}, 1, wxALL|wxEXPAND|wxADJUST_MINSIZE, 5);
	$self->SetAutoLayout(1);
	$self->SetSizer($self->{sz_main});
	$self->{sz_main}->Fit($self);
	$self->{sz_main}->SetSizeHints($self);
	$self->Layout();

# end wxGlade
}

sub closehandler {
    my ($self) = @_;
    @{$config->mainw}{qw(xpos ypos xwidth ywidth)} = ($self->GetPositionXY, $self->GetSizeWH);

    # Explicitly destroy the hidden (but still alive!) dialogs.
    foreach ( qw(opendialog) ) {
	next unless $self->{"d_$_"};
	$self->{"d_$_"}->Destroy;
    }
}

sub command {
    my ($self, $cmd) = @_;
    use Wx qw(wxEVT_COMMAND_MENU_SELECTED);

    foreach ( split(":", $cmd) ) {
	if ( exists($cmds{$_}) ) {
	    Wx::PostEvent($self,
			  Wx::CommandEvent->new(wxEVT_COMMAND_MENU_SELECTED, $cmds{$_}));
	}
	else {
	    Wx::LogMessage("Unknown command: $_");
	}
    }

}

sub dagboekenmenu {
    my $self = shift;
    my $sth = $dbh->sql_exec("SELECT dbk_id,dbk_desc,dbk_type".
			     " FROM Dagboeken".
			     " ORDER BY dbk_desc");

    use Wx::Event qw(EVT_MENU);

    my $tmp = Wx::Menu->new;
    while ( my $rr = $sth->fetchrow_arrayref ) {
	my ($id, $desc, $type) = @$rr;
	# This consumes Ids, but we do not expect to do this often.
	my $m = Wx::NewId();
	$tmp->Append($m, "$desc\tAlt-$id", "Dagboek $desc");
	$type = qw(X IV IV BKM BKM BKM)[$type];
	undef($self->{"d_dbkpanel$id"});
	EVT_MENU($self, $m,
		 sub {
		       ::set_status(">>> [$id] Dagboek $desc, id = $id, type = $type");
		       require "${type}Panel.pm";
		       $self->{"d_dbkpanel$id"} ||=
			 "${type}Panel"->new($self, -1,
					     "Dagboek $desc");
		       ### TODO: How to save/restore geometry?
		       $self->{"d_dbkpanel$id"}->init($id, $desc);
		       $self->{"d_dbkpanel$id"}->Show(1);
		   });
    }

    my $ix = $self->{mainframe_menubar}->FindMenu("Dagboeken");
    $tmp = $self->{mainframe_menubar}->Replace
      ($ix, $tmp,
       $self->{mainframe_menubar}->GetLabelTop($ix));
    $tmp->Destroy if $tmp;
}

sub DESTROY {
    my $self = shift;
    Wx::Log::SetActiveTarget($self->{OLDLOG})->Destroy;
}

# wxGlade: MainFrame::OnNew <event_handler>
sub OnNew {
    my ($self, $event) = @_;
    use NewDialog;
    foreach my $win ( grep(/^d_m\S+panel$/, keys(%$self)) ) {
	next unless $self->{$win};
	next unless $self->{$win}->IsShown;
	Wx::MessageBox("Er zijn nog onderhoudsvensters open op de huidige database.\n".
		       "Deze dienen eerst te worden gesloten.",
		       "Open vensters",
		       wxOK|wxICON_ERROR);
	return;
    }
    $self->{d_newdialog} ||= NewDialog->new($self, -1,
					    "Nieuwe administratie",
					    [$config->neww->{xpos},$config->neww->{ypos}],
					    [$config->neww->{xwidth},$config->neww->{ywidth}],
					   );
    $self->{d_newdialog}->SetSize([$config->neww->{xwidth},$config->neww->{ywidth}]);
    my $ret = $self->{d_newdialog}->ShowModal;
    $self->{d_newdialog}->Destroy;
    $self->{d_newdialog} = undef;
}

# wxGlade: MainFrame::OnNewWiz <event_handler>
sub OnNewWiz {
    my ($self, $event) = @_;
    require NewDialogWiz;
    foreach my $win ( grep(/^d_m\S+panel$/, keys(%$self)) ) {
	next unless $self->{$win};
	next unless $self->{$win}->IsShown;
	Wx::MessageBox("Er zijn nog onderhoudsvensters open op de huidige database.\n".
		       "Deze dienen eerst te worden gesloten.",
		       "Open vensters",
		       wxOK|wxICON_ERROR);
	return;
    }
    $self->{d_newdialog} ||= NewDialogWiz->new($self, -1,
					    "Nieuwe administratie",
					    [$config->neww->{xpos},$config->neww->{ypos}],
					    [$config->neww->{xwidth},$config->neww->{ywidth}],
					   );
    $self->{d_newdialog}->SetSize([$config->neww->{xwidth},$config->neww->{ywidth}]);
    my $ret = $self->{d_newdialog}->ShowModal;
    $self->{d_newdialog}->Destroy;
    $self->{d_newdialog} = undef;
}

sub OnNewXxx {
    my ($self, $event) = @_;
    require AccDialog;
    $self->{d_xxxdialog} ||= AccDialog->new($self, -1,
					    "Nieuwe administratie",
					    [$config->neww->{xpos},$config->neww->{ypos}],
					    [$config->neww->{xwidth},$config->neww->{ywidth}],
					   );
    $self->{d_xxxdialog}->SetSize([$config->neww->{xwidth},$config->neww->{ywidth}]);
    my $ret = $self->{d_xxxdialog}->ShowModal;
    $self->{d_xxxdialog}->Destroy;
    $self->{d_xxxdialog} = undef;
}

# wxGlade: MainFrame::OnOpen <event_handler>
sub OnOpen {
    my ($self, $event) = @_;
    require DbOpenDialog;
    foreach my $win ( grep(/^d_m\S+panel$/, keys(%$self)) ) {
	next unless $self->{$win};
	next unless $self->{$win}->IsShown;
	Wx::MessageBox("Er zijn nog onderhoudsvensters open op de huidige database.\n".
		       "Deze dienen eerst te worden gesloten.",
		       "Open vensters",
		       wxOK|wxICON_ERROR);
	return;
    }
    $self->{d_opendialog} ||= DbOpenDialog->new($self, -1,
						"Openen database",
						[$config->openw->{xpos},$config->openw->{ypos}],
						[$config->openw->{xwidth},$config->openw->{ywidth}],
					       );
    $self->{d_opendialog}->SetSize([$config->openw->{xwidth},$config->openw->{ywidth}]);
    $self->{d_opendialog}->refresh;
    return unless $self->{d_opendialog}->ShowModal;

    # Refresh existing reports.
    foreach my $win ( grep(/^d_m\S+panel$/, keys(%$self)) ) {
	next unless $self->{$win};
	next unless $self->{$win}->IsShown;
	$self->{$win}->refresh;
    }
}

# wxGlade: MainFrame::OnClose <event_handler>
sub OnClose {
    my ($self, $event) = @_;
    $event->Skip;
}

# wxGlade: MainFrame::OnPreferences <event_handler>
sub OnPreferences {
	my ($self, $event) = @_;
	$event->Skip;
}

# wxGlade: MainFrame::OnLogw <event_handler>
sub OnLogw {
    my ($self, $event) = @_;
    if ( $self->{tx_log}->IsShown ) {
	$self->{tx_log}->Show(0);
	$self->{mainframe_menubar}->SetLabel(MENU_LOGW, "Toon log venster");
    }
    else {
	$self->{tx_log}->Show(1);
	$self->{mainframe_menubar}->SetLabel(MENU_LOGW, "Verberg log venster");
    }
    $self->Layout;
}

# wxGlade: MainFrame::OnLogClean <event_handler>
sub OnLogClean {
    my ($self, $event) = @_;
    $self->{tx_log}->Clear;
}

# wxGlade: MainFrame::OnRestart <event_handler>
sub OnRestart {
    my ($self, $event) = @_;
    $self->closehandler(@_);
    $::restart++;
    $self->Close(1);
}

# wxGlade: MainFrame::OnExit <event_handler>
sub OnExit {
    my ($self, $event) = @_;
    $self->closehandler(@_);
    $self->Destroy;
}

# wxGlade: MainFrame::OnMGbk <event_handler>
sub OnMGbk {
    my ($self, $event) = @_;
    require AccPanel;
    my $p = "d_maccpanel";
    $self->{$p} ||= AccPanel->new($self, -1,
				  "Onderhoud Grootboekrekeningen",
				  [$config->accw->{xpos},$config->accw->{ypos}],
				  [$config->accw->{xwidth},$config->accw->{ywidth}],
				 );
    $self->{$p}->Move([$config->accw->{xpos},$config->accw->{ypos}]);
    $self->{$p}->SetSize([$config->accw->{xwidth},$config->accw->{ywidth}]);
    $self->{$p}->Show(1);
}

# wxGlade: MainFrame::OnMRel <event_handler>
sub OnMRel {
    my ($self, $event) = @_;
    require RelPanel;
    my $p = "d_mrelpanel";
    $self->{$p} ||= RelPanel->new($self, -1,
				  "Onderhoud Relaties",
				  [$config->relw->{xpos},$config->relw->{ypos}],
				  [$config->relw->{xwidth},$config->relw->{ywidth}],
				 );
    $self->{$p}->SetSize([$config->relw->{xwidth},$config->relw->{ywidth}]);
    $self->{$p}->Show(1);
}

# wxGlade: MainFrame::OnMBtw <event_handler>
sub OnMBtw {
    my ($self, $event) = @_;
    require BtwPanel;
    my $p = "d_mbtwpanel";
    $self->{$p} ||= BtwPanel->new($self, -1,
				  "Onderhoud BTW instellingen",
				  [$config->btww->{xpos},$config->btww->{ypos}],
				  [$config->btww->{xwidth},$config->btww->{ywidth}],
				 );
    $self->{$p}->SetSize([$config->btww->{xwidth},$config->btww->{ywidth}]);
    $self->{$p}->Show(1);
}

# wxGlade: MainFrame::OnMStdAcc <event_handler>
sub OnMStdAcc {
    my ($self, $event) = @_;
    require MStdAccPanel;
    my $p = "d_mstdpanel";
    $self->{$p} ||= MStdAccPanel->new($self, -1,
				      "Onderhoud Koppelingen",
				      [$config->stdw->{xpos},$config->stdw->{ypos}],
				      [$config->stdw->{xwidth},$config->stdw->{ywidth}],
				     );
    $self->{$p}->SetSize([$config->stdw->{xwidth},$config->stdw->{ywidth}]);
    $self->{$p}->Show(1);
}

# wxGlade: MainFrame::OnRPrf <event_handler>
sub OnRPrf {
    my ($self, $event) = @_;
    require RepBalRes;
    $self->{d_rprfpanel} ||= RepBalRes->new($self, -1,
					    "Resultaat",
					    [$config->rprfw->{xpos},$config->rprfw->{ypos}],
					    [$config->rprfw->{xwidth},$config->rprfw->{ywidth}],
					   );
    $self->{d_rprfpanel}->SetSize([$config->rprfw->{xwidth},$config->rprfw->{ywidth}]);
    $self->{d_rprfpanel}->init("prf");
    $self->{d_rprfpanel}->Show(1);
}

# wxGlade: MainFrame::OnRBal <event_handler>
sub OnRBal {
    my ($self, $event) = @_;
    require RepBalRes;
    $self->{d_rbalpanel} ||= RepBalRes->new($self, -1,
					    "Balans",
					    [$config->rbalw->{xpos},$config->rbalw->{ypos}],
					    [$config->rbalw->{xwidth},$config->rbalw->{ywidth}],
					   );
    $self->{d_rbalpanel}->SetSize([$config->rbalw->{xwidth},$config->rbalw->{ywidth}]);
    $self->{d_rbalpanel}->init("bal");
    $self->{d_rbalpanel}->Show(1);
}

# wxGlade: MainFrame::OnRRes <event_handler>
sub OnRRes {
    my ($self, $event) = @_;
    require RepBalRes;
    $self->{d_rrespanel} ||= RepBalRes->new($self, -1,
					    "Resultaat",
					    [$config->rresw->{xpos},$config->rresw->{ypos}],
					    [$config->rresw->{xwidth},$config->rresw->{ywidth}],
					   );
    $self->{d_rrespanel}->SetSize([$config->rresw->{xwidth},$config->rresw->{ywidth}]);
    $self->{d_rrespanel}->init("res");
    $self->{d_rrespanel}->Show(1);
}

# wxGlade: MainFrame::OnRGbk <event_handler>
sub OnRGbk {
    my ($self, $event) = @_;
    require RepGrootboek;
    $self->{d_rgbkpanel} ||= RepGrootboek->new($self, -1,
					       "Grootboek",
					       [$config->rgbkw->{xpos},$config->rgbkw->{ypos}],
					       [$config->rgbkw->{xwidth},$config->rgbkw->{ywidth}],
					      );
    $self->{d_rgbkpanel}->SetSize([$config->rgbkw->{xwidth},$config->rgbkw->{ywidth}]);
    $self->{d_rgbkpanel}->Show(1);
}

# wxGlade: MainFrame::OnRJnl <event_handler>
sub OnRJnl {
    my ($self, $event) = @_;
    require RepJournaal;
    $self->{d_rjnlpanel} ||= RepJournaal->new($self, -1,
					      "Journaal",
					      [$config->rjnlw->{xpos},$config->rjnlw->{ypos}],
					      [$config->rjnlw->{xwidth},$config->rjnlw->{ywidth}],
					     );
    $self->{d_rjnlpanel}->SetSize([$config->rjnlw->{xwidth},$config->rjnlw->{ywidth}]);
    $self->{d_rjnlpanel}->Show(1);
}

# wxGlade: MainFrame::OnRBtw <event_handler>
sub OnRBtw {
    my ($self, $event) = @_;
    require RepBtw;
    $self->{d_rbtwpanel} ||= RepBtw->new($self, -1,
					 "BTW aangifte",
					 [$config->rbtww->{xpos},$config->rbtww->{ypos}],
					 [$config->rbtww->{xwidth},$config->rbtww->{ywidth}],
					);
    $self->{d_rbtwpanel}->SetSize([$config->rbtww->{xwidth},$config->rbtww->{ywidth}]);
    $self->{d_rbtwpanel}->Show(1);
}

# wxGlade: MainFrame::OnRDeb <event_handler>
sub OnRDeb {
    my ($self, $event) = @_;
    require RepDebCrd;
    $self->{d_rdebpanel} ||= RepDebCrd->new($self, -1,
					    "Debiteuren",
					    [$config->rdebw->{xpos},$config->rdebw->{ypos}],
					    [$config->rdebw->{xwidth},$config->rdebw->{ywidth}],
					   );
    $self->{d_rdebpanel}->SetSize([$config->rdebw->{xwidth},$config->rdebw->{ywidth}]);
    $self->{d_rdebpanel}->init("deb");
    $self->{d_rdebpanel}->Show(1);
}

# wxGlade: MainFrame::OnRCrd <event_handler>
sub OnRCrd {
    my ($self, $event) = @_;
    require RepDebCrd;
    $self->{d_rcrdpanel} ||= RepDebCrd->new($self, -1,
					    "Crediteuren",
					    [$config->rcrdw->{xpos},$config->rcrdw->{ypos}],
					    [$config->rcrdw->{xwidth},$config->rcrdw->{ywidth}],
					   );
    $self->{d_rcrdpanel}->SetSize([$config->rcrdw->{xwidth},$config->rcrdw->{ywidth}]);
    $self->{d_rcrdpanel}->init("crd");
    $self->{d_rcrdpanel}->Show(1);
}

# wxGlade: MainFrame::OnAbout <event_handler>
sub OnAbout {
    my ($self, $event) = @_;
    Wx::MessageBox("$::appname -- Squirrel Consultancy\n".
		   "wxPerl version $Wx::VERSION\n".
		   "wxWidgets version ".Wx::wxVERSION,
		   "Info...",
		   wxOK,
		   $self);
}

# end of class MainFrame

1;

