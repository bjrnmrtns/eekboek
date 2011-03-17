# generated by wxGlade 0.5cvs on Fri Aug  3 21:56:01 2007 from /home/jv/src/eekboek/src/wxeb/wxeb.wxg
# To get wxPerl visit http://wxPerl.sourceforge.net/

use Wx 0.15 qw[:allclasses];
use strict;

package EB::Wx::Shell::MainFrame;

use EekBoek;
use Wx qw[:everything];
use base qw(Wx::Frame);
use base qw(EB::Wx::Shell::Window);
use strict;
use utf8;
use Encode;
use File::Spec;

# begin wxGlade: ::dependencies
use Wx::Locale gettext => '_T';
# end wxGlade

use EB;
use EB::Wx::Shell::HtmlViewer;
use EB::Wx::Shell::EditDialog;
use EB::Wx::Shell::PreferencesDialog;
use Wx::Perl::ProcessStream qw[:everything];

my $prefctl;

################ Locale ################

# Variable expansion. See GNU gettext for details.
sub __expand($%) {
    my ($t, %args) = @_;
    my $re = join('|', map { quotemeta($_) } keys(%args));

    #### WHOAH!!!!!
    # $1 seems to be stuck to the EekBoek initial message.
    #### WHOAH!!!!!

    $t =~ s/(\{)($re)\}/defined($args{$2}) ? $args{$2} : "{$2}"/ge;
    $t;
}

# Translation w/ variables.
sub __x($@) {
    my ($t, %vars) = @_;
    __expand(_T($t), %vars);
}

# Translation w/ singular/plural handling.
sub __n($$$) {
    my ($sing, $plur, $n) = @_;
    _T($n == 1 ? $sing : $plur);
}

# Translation w/ singular/plural handling and variables.
sub __nx($$$@) {
    my ($sing, $plur, $n, %vars) = @_;
    __expand(__n($sing, $plur, $n), %vars);
}

# Make __xn a synonym for __nx.
*__xn = \&__nx;

################ Locale ################

sub new {
	my( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

	use constant MENU_INPUTEDIT => Wx::NewId();
	use constant MENU_INPUTEXEC => Wx::NewId();
	use constant MENU_REP_TRIAL => Wx::NewId();
	use constant MENU_REP_BAL_ACT => Wx::NewId();
	use constant MENU_REP_BAL_MGP => Wx::NewId();
	use constant MENU_REP_BAL_GRP => Wx::NewId();
	use constant MENU_REP_BAL_GAC => Wx::NewId();
	use constant MENU_REP_RES_ACT => Wx::NewId();
	use constant MENU_REP_RES_MGP => Wx::NewId();
	use constant MENU_REP_RES_GRP => Wx::NewId();
	use constant MENU_REP_RES_GAC => Wx::NewId();
	use constant MENU_REP_JNL => Wx::NewId();
	use constant MENU_REP_UN => Wx::NewId();
	use constant MENU_REP_AP => Wx::NewId();
	use constant MENU_REP_AR => Wx::NewId();
	use constant MENU_REP_VAT => Wx::NewId();

# begin wxGlade: EB::Wx::Shell::MainFrame::new

	$style = wxDEFAULT_FRAME_STYLE 
		unless defined $style;

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
	$self->{p_dummy} = Wx::Panel->new($self, -1, wxDefaultPosition, wxDefaultSize, );
	$self->__set_menubar();
	$self->{s_input_staticbox} = Wx::StaticBox->new($self->{p_dummy}, -1, _T("Input") );
	$self->{statusbar} = $self->CreateStatusBar(1, wxST_SIZEGRIP);
	$self->{t_output} = Wx::TextCtrl->new($self->{p_dummy}, -1, "", wxDefaultPosition, wxDefaultSize, wxTE_MULTILINE|wxTE_READONLY|wxHSCROLL);
	$self->{b_edit} = Wx::BitmapButton->new($self->{p_dummy}, -1, (Wx::Bitmap->new("edit.png", wxBITMAP_TYPE_ANY)));
	$self->{t_input} = Wx::TextCtrl->new($self->{p_dummy}, -1, "", wxDefaultPosition, wxDefaultSize, wxTE_PROCESS_ENTER|wxTE_PROCESS_TAB);
	$self->{b_send} = Wx::BitmapButton->new($self->{p_dummy}, -1, (Wx::Bitmap->new("button_ok.png", wxBITMAP_TYPE_ANY)));

	$self->__set_properties();
	$self->__do_layout();

	Wx::Event::EVT_BUTTON($self, $self->{b_edit}->GetId, \&OnEdit);
	Wx::Event::EVT_TEXT_ENTER($self, $self->{t_input}->GetId, \&OnTextEnter);
	Wx::Event::EVT_BUTTON($self, $self->{b_send}->GetId, \&OnSend);

# end wxGlade


	Wx::Event::EVT_MENU($self, wxID_OPEN, \&OnOpen);
	Wx::Event::EVT_MENU($self, wxID_PREFERENCES, \&OnPrefs);
	Wx::Event::EVT_MENU($self, wxID_EXIT, \&OnQuit);

	Wx::Event::EVT_MENU($self, wxID_CLEAR, \&OnClear);
	Wx::Event::EVT_MENU($self, MENU_INPUTEDIT, \&OnEdit);
	Wx::Event::EVT_MENU($self, MENU_INPUTEXEC, \&OnSend);

	Wx::Event::EVT_MENU($self, MENU_REP_TRIAL, \&OnTrial);

	my $i = -1;
	for ( MENU_REP_BAL_ACT, MENU_REP_BAL_MGP,
	      MENU_REP_BAL_GRP, MENU_REP_BAL_GAC,) {
	    my $sub = $i++;
	    Wx::Event::EVT_MENU($self, $_, sub { push(@_, $sub); &OnMenuBal });
	}
	$i = -1;
	for ( MENU_REP_RES_ACT, MENU_REP_RES_MGP,
	      MENU_REP_RES_GRP, MENU_REP_RES_GAC,) {
	    my $sub = $i++;
	    Wx::Event::EVT_MENU($self, $_, sub { push(@_, $sub); &OnMenuRes });
	}

	Wx::Event::EVT_MENU($self, MENU_REP_JNL, \&OnJournal);
	Wx::Event::EVT_MENU($self, MENU_REP_UN,  \&OnMenuUns);
	Wx::Event::EVT_MENU($self, MENU_REP_AP,  \&OnMenuAP);
	Wx::Event::EVT_MENU($self, MENU_REP_AR,  \&OnMenuAR);
	Wx::Event::EVT_MENU($self, MENU_REP_VAT, \&OnMenuVAT);

	Wx::Event::EVT_MENU($self, wxID_HELP,  \&OnHelp);
	Wx::Event::EVT_MENU($self, wxID_ABOUT, \&OnAbout);

	#### End of MenuBar

	Wx::Event::EVT_CLOSE($self, \&OnQuit);

	Wx::Event::EVT_CHAR($self->{t_input}, sub { $self->OnChar(@_) });
#	Wx::Event::EVT_IDLE($self, \&OnIdle);

	EVT_WXP_PROCESS_STREAM_STDOUT( $self, \&evt_process_stdout);
	EVT_WXP_PROCESS_STREAM_STDERR( $self, \&evt_process_stderr);
	EVT_WXP_PROCESS_STREAM_EXIT(   $self, \&evt_process_exit);

	$prefctl ||=
	  {
	   repwin      => 0,
	   errorpopup  => 1,
	   warnpopup   => 1,
	   infopopup   => 0,
	   histlines   => 200,
	  };

	$self->SetSize(801, 551);
	$self->sizepos_restore("main");

	return $self;
}

sub __set_menubar {
    my $self = shift;
	# Unfortunately, due to an error in wxGlade sub-menu
	# generation we need to do it ourselves. All...

	$self->{menubar} = Wx::MenuBar->new();
	my $wxglade_tmp_menu;
	$wxglade_tmp_menu = Wx::Menu->new();
	$wxglade_tmp_menu->Append(wxID_OPEN, _T("&Open\tCtrl-O"), "");
	$wxglade_tmp_menu->AppendSeparator();
	$wxglade_tmp_menu->Append(wxID_PREFERENCES, _T("Prefere&nces..."), "");
	$wxglade_tmp_menu->AppendSeparator();
	$wxglade_tmp_menu->Append(wxID_EXIT, _T("E&xit\tCtrl-Q"), "");
	$self->{_T("menubar")}->Append($wxglade_tmp_menu, _T("&File"));
	$wxglade_tmp_menu = Wx::Menu->new();
	$wxglade_tmp_menu->Append(MENU_INPUTEDIT, _T("&Edit input line\tCtrl+Enter"), "");
	$wxglade_tmp_menu->Append(MENU_INPUTEXEC, _T("E&xecute input line\tEnter"), "");
	$wxglade_tmp_menu->AppendSeparator();
	$wxglade_tmp_menu->Append(wxID_CLEAR, _T("&Clear output"), "");
	$self->{_T("menubar")}->Append($wxglade_tmp_menu, _T("&Edit"));
	$self->{_T("Reports")} = Wx::Menu->new();
	$self->{_T("Reports")}->Append(MENU_REP_TRIAL, _T("Trial"), "");
	$self->{_T("Reports_bal")} = Wx::Menu->new();
	$self->{_T("Reports_bal")}->Append(MENU_REP_BAL_ACT, _T("By account"), "");
	$self->{_T("Reports_bal")}->AppendSeparator();
	$self->{_T("Reports_bal")}->Append(MENU_REP_BAL_MGP, _T("By master group"), "");
	$self->{_T("Reports_bal")}->Append(MENU_REP_BAL_GRP, _T("By group"), "");
	$self->{_T("Reports_bal")}->Append(MENU_REP_BAL_GAC, _T("Detailed"), "");
	$self->{_T("Reports")}->Append(Wx::NewId(), _T("Balance"), $self->{_T("Reports_bal")}, "");
	$self->{_T("Reports_res")} = Wx::Menu->new();
	$self->{_T("Reports_res")}->Append(MENU_REP_RES_ACT, _T("By account"), "");
	$self->{_T("Reports_res")}->AppendSeparator();
	$self->{_T("Reports_res")}->Append(MENU_REP_RES_MGP, _T("By master group"), "");
	$self->{_T("Reports_res")}->Append(MENU_REP_RES_GRP, _T("By group"), "");
	$self->{_T("Reports_res")}->Append(MENU_REP_RES_GAC, _T("Detailed"), "");
	$self->{_T("Reports")}->Append(Wx::NewId(), _T("Results"), $self->{_T("Reports_res")}, "");
	$self->{_T("Reports")}->AppendSeparator();
	$self->{_T("Reports")}->Append(MENU_REP_JNL, _T("Journal"), "");
	$self->{_T("Reports")}->AppendSeparator();
	$self->{_T("Reports")}->Append(MENU_REP_UN, _T("Unsettled Accounts"), "");
	$self->{_T("Reports")}->AppendSeparator();
	$self->{_T("Reports")}->Append(MENU_REP_AP, _T("Accounts Payable"), "");
	$self->{_T("Reports")}->Append(MENU_REP_AR, _T("Accounts Receivable"), "");
	$self->{_T("Reports")}->AppendSeparator();
	$self->{_T("Reports")}->Append(MENU_REP_VAT, _T("VAT Report"), "");
	$self->{_T("menubar")}->Append($self->{_T("Reports")}, _T("&Reports"));
	$wxglade_tmp_menu = Wx::Menu->new();
	$wxglade_tmp_menu->Append(wxID_HELP, _T("&Help..."), "");
	$wxglade_tmp_menu->Append(wxID_ABOUT, _T("&About..."), "");
	$self->{_T("menubar")}->Append($wxglade_tmp_menu, _T("&Help"));
	$self->SetMenuBar($self->{menubar});
}

sub __set_properties {
	my $self = shift;

# begin wxGlade: EB::Wx::Shell::MainFrame::__set_properties

	$self->SetTitle(_T("EekBoek"));
	$self->SetSize(Wx::Size->new(800, 550));
	$self->{statusbar}->SetStatusWidths(-1);
	
	my( @statusbar_fields ) = (
		""
	);

	if( @statusbar_fields ) {
		$self->{statusbar}->SetStatusText($statusbar_fields[$_], $_) 	
		for 0 .. $#statusbar_fields ;
	}
	$self->{b_edit}->SetSize($self->{b_edit}->GetBestSize());
	$self->{t_input}->SetFocus();
	$self->{b_send}->SetSize($self->{b_send}->GetBestSize());

# end wxGlade

	my $f = Wx::SystemSettings::GetFont(wxSYS_DEFAULT_GUI_FONT);
	$self->{t_output}->SetFont(Wx::Font->new($f->GetPointSize, wxMODERN, wxNORMAL, wxNORMAL, 0, ""));

}

sub __do_layout {
	my $self = shift;

# begin wxGlade: EB::Wx::Shell::MainFrame::__do_layout

	$self->{sz_dummy} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{s_main} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{s_layout} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{s_input}= Wx::StaticBoxSizer->new($self->{s_input_staticbox}, wxHORIZONTAL);
	$self->{s_output} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{s_output}->Add($self->{t_output}, 1, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{s_layout}->Add($self->{s_output}, 1, wxEXPAND, 0);
	$self->{s_input}->Add($self->{b_edit}, 0, wxRIGHT|wxADJUST_MINSIZE, 5);
	$self->{s_input}->Add($self->{t_input}, 1, wxEXPAND|wxADJUST_MINSIZE, 0);
	$self->{s_input}->Add($self->{b_send}, 0, wxLEFT|wxADJUST_MINSIZE, 5);
	$self->{s_layout}->Add($self->{s_input}, 0, wxEXPAND, 0);
	$self->{s_main}->Add($self->{s_layout}, 1, wxALL|wxEXPAND, 5);
	$self->{p_dummy}->SetSizer($self->{s_main});
	$self->{sz_dummy}->Add($self->{p_dummy}, 1, wxEXPAND, 0);
	$self->SetSizer($self->{sz_dummy});
	$self->Layout();
	$self->SetSize(Wx::Size->new(800, 550));

# end wxGlade
}

sub RunCommand {
    my ($self, $cmd) = @_;
    unless ( defined $self->{_proc} ) {
	unless ( $self->{_ebcfg} && -s $self->{_ebcfg} ) {
	    my $md = Wx::MessageDialog->new
	      ($self,
	       _T("Please select a valid .eekboek.conf first"),
	       _T("Missing config"), wxOK|wxICON_INFORMATION,
	       wxDefaultPosition);
	    $md->ShowModal;
	    $md->Destroy;
	    $self->OnOpen;
	    return;
	}
	my @eb;
	if ( $Cava::Packager::PACKAGED ) {
            @eb = ( Cava::Packager::GetBinPath() . "/ebshell" );
	}
	else {
	    @eb = ( $^X, File::Spec->catfile( $::bin, "ebshell" ) );
	    #$eb[2] = "ebshell.pl" if $^O =~ /mswin/i;
	}
	push(@eb, "-f", $self->{_ebcfg}) if $self->{_ebcfg};
	$self->{_proc} =
	  Wx::Perl::ProcessStream->OpenProcess(\@eb, 'EekBoek', $self);
	$self->{_pid} =	$self->{_proc}->GetProcessId;
	warn("STARTED: @eb\n");
    }

    $cmd = "database" unless defined $cmd;
    $self->{t_output}->AppendText("eb> ");
    $self->ShowText($cmd, wxBLUE);
    if ( $cmd =~ /^(balans|result|proefensaldibalans|journaal|openstaand|(?:deb|cred)iteuren|btwaangifte)(?:\s|$)/ ) {
	$cmd .= " --gen-wxhtml";
    }
    $self->{_proc}->WriteProcess(encode("utf-8", $cmd."\n"));
}

sub ShowText {
    my ($self, $text, $colour) = @_;
    if ( $colour ) {
	my $t = Wx::TextAttr->new;
	$t->SetTextColour($colour);
	my $x0 = $self->{t_output}->GetLastPosition;
	$self->{t_output}->AppendText($text."\n");
	$self->{t_output}->SetStyle($x0, $self->{t_output}->GetLastPosition, $t);
    }
    else {
	$self->{t_output}->AppendText($text."\n");
    }
}

my $capturing;
sub evt_process_stdout {
    my ($self, $event) = @_;
    #$event->Skip(1);
    my $out = decode("utf-8", $event->GetLine);
    # warn("app: $out\n");
    if ( $capturing || $out eq "<html>" ) {
	$capturing .= $out . "\n";
	if ( $out eq "<html>" ) {
	    $self->SetCursor(wxHOURGLASS_CURSOR);
	}
	elsif ( $out eq "</html>" ) {
	    $self->SetCursor(wxNullCursor);
	    my ($title) = ($capturing =~ m{<title>(.+?)</title>});
	    #warn("captured $title: ", length($capturing), " characters\n");
	    my $panel = $self->{prefs_repwin} ? "d_htmlpanel" : "d_htmlpanel_$title";
	    $self->{$panel} ||= EB::Wx::Shell::HtmlViewer->new
	      ($self, -1, $title);
	    $self->{$panel}->Show(0);
	    $self->{$panel}->html->SetPage($capturing);
	    $self->{$panel}->htmltext = $capturing;
	    $self->{$panel}->SetTitle($title);
	    $self->{$panel}->Show(1);
	    $capturing = "";
	}
    }
    else {
	$self->{t_output}->AppendText($out."\n");
    }
}

sub evt_process_stderr {
    my ($self, $event) = @_;
    #$event->Skip(1);
    my $out = decode("utf-8", $event->GetLine);
    # warn("err: $out\n");
    $self->ProcessMessages($out);
}

sub evt_process_exit {
    my ($self, $event) = @_;
    #$event->Skip(1);
    my $process = $event->GetProcess;
    my $pid = $process->GetProcessId;
    #my $line = $event->GetLine;
    #my @buffers = @{ $process->GetStdOutBuffer };
    #my @errors = @{ $process->GetStdOutBuffer };
    #my $exitcode = $process->GetExitCode;
    return if $self->{_pid} && $self->{_pid} != $pid;
    $process->Destroy;
    my $md = Wx::MessageDialog->new
      ($self,
       _T("EekBoek program has finished"),
       _T("Finished"), wxOK|wxICON_INFORMATION,
       wxDefaultPosition);
    $md->ShowModal;
    $md->Destroy;
    $self->OnQuit;
}

sub ProcessMessages {
    my ($self, $err) = @_;
    return unless $err;
    my @err = split(/\n+/, $err);
    while ( @err ) {
	$err = shift(@err);
	if ( $err =~ /^(EekBoek\s+([0-9.]+).*)/ ) {
	    $self->{statusbar}->SetStatusText($1, 0);
	    $self->{_eb} = $2;
	    next;
	}
	my @i;
	if ( $err =~ /^\?+(.*)/ ) {
	    $self->ShowText($err, wxRED);
	    next unless $self->{prefs_errorpopup};
	    @i = ($1, _T("Error"), wxOK|wxICON_ERROR);
	}
	elsif ( $err =~ /^\!+(.*)/ ) {
	    $self->ShowText($err, Wx::Colour->new("magenta"));
	    next unless $self->{prefs_warnpopup};
	    @i = ($1, _T("Warning"), wxOK|wxICON_WARNING);
	}
	else {
	    $self->ShowText($err, wxGREEN);
	    next unless $self->{prefs_infopopup};
	    @i = ($err, _T("Information"), wxOK|wxICON_INFORMATION);
	}
	my $md = Wx::MessageDialog->new($self, @i, wxDefaultPosition);
	$md->ShowModal;
	$md->Destroy;
    }
}


sub OnTextEnter {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnTextEnter <event_handler>

	my $cmd = $self->{t_input}->GetValue;
	return unless $cmd;
	push(@{$self->{_cmd}}, $cmd)
	  unless $cmd eq $self->{_cmd}->[-1];
	$self->{_cmdptr} = $#{$self->{_cmd}} + 1;
	$self->{t_input}->SetValue("");
	$cmd =~ s/ *\t */ /g;
	$self->RunCommand($cmd);
	$self->{t_input}->SetFocus();

# end wxGlade
}

sub OnSend {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnSend <event_handler>

	&OnTextEnter;

# end wxGlade
}

sub OnEdit {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnEdit <event_handler>

	my $d = $self->{d_editdialog} ||= EB::Wx::Shell::EditDialog->new;

	my $t = $self->{t_input}->GetValue;
	$t =~ s/\t/\n/g;
	$d->{t_input}->SetValue($t);
	$d->{t_input}->SetInsertionPoint( $self->{t_input}->GetInsertionPoint );
	$d->{t_input}->SetFocus;

	my $ret = $d->ShowModal;

	$d->Show(0);

	return unless $ret == wxID_APPLY;

	$t = $d->{t_input}->GetValue;
	$t =~ s/\n/\t/g;
	$self->{t_input}->SetValue($t);

	&OnTextEnter;

# end wxGlade
}

sub OnOpen {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnOpen <event_handler>

	my $fd = Wx::FileDialog->new
	  ($self,
	   _T("Choose"),
	   "", "",
	   ".eekboek.conf;eekboek.conf",
	   0|wxFD_FILE_MUST_EXIST,
	   wxDefaultPosition);
	my $ret = $fd->ShowModal;
	if ( $ret == wxID_OK ) {
	    if ( $self->{_proc} ) {
		$self->{_proc}->TerminateProcess;
		undef $self->{_proc};
		undef $self->{_pid};
	    }
	    $self->{_ebcfg} = $fd->GetPath;
	    $self->RunCommand(undef);
	}
	$fd->Destroy;

# end wxGlade
}

sub OnQuit {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnQuit <event_handler>
	$self->SaveHistory;
	$self->sizepos_save;
	$self->SavePreferences;

	foreach ( grep( /^d_htmlpanel/, keys(%$self) ) ) {
	    $self->{$_}->OnClose;
	}

	foreach ( grep( /^d_.*dialog/, keys(%$self) ) ) {
	    $self->{$_}->Destroy;
	}

	$self->Destroy;

# end wxGlade
}

sub PutOnHistory {
    my ($self, $cmd) = @_;
    return if $cmd eq "";
    $cmd =~ s/\s+--gen-wxhtml//;

    return if @{$self->{_cmd}} && $cmd eq $self->{_cmd}->[-1];

    return if exists $self->{_cmd}->[$self->{_cmdptr}]
      && $cmd eq $self->{_cmd}->[$self->{_cmdptr}];

    push(@{$self->{_cmd}}, $cmd);
}

use Wx qw(:keycode);

sub OnChar {
    my ($self, $ctl, $event) = @_;

    # Get key code and char, if ordinary.
    my $k = $event->GetKeyCode;
    my $c = ($k < WXK_START) ? pack("C", $k) : "";

    if ( $k == WXK_UP
	 && $self->{_cmdptr} > 0 ) {
	$self->PutOnHistory($ctl->GetValue);
	$ctl->SetValue($self->{_cmd}->[--$self->{_cmdptr}]);
	$ctl->SetInsertionPointEnd;
    }
    elsif ( $k == WXK_DOWN
	 && $self->{_cmdptr} < $#{$self->{_cmd}} ) {
	$self->PutOnHistory($ctl->GetValue);
	$ctl->SetValue($self->{_cmd}->[++$self->{_cmdptr}]);
	$ctl->SetInsertionPointEnd;
    }
    elsif ( $k == WXK_RETURN && $event->ControlDown ) {
	$self->OnEdit($event);
    }
    elsif (
	 $k == WXK_TAB     ||
	 $k == WXK_RETURN  ||
	 $k >= WXK_START   ||
	 $event->HasModifiers
       ) {
	# Common controls.
	$event->Skip;
	return;
    }
    else {
	$event->Skip;
    }
}


sub OnHelp {
    my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnHelp <event_handler>

    require EB::Wx::Help;
    my $h = EB::Wx::Help->new;
    $h->show_html_help;

# end wxGlade
}

sub OnAbout {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnAbout <event_handler>

	my $year = 1900 + (localtime(time))[5];

	my $md = Wx::MessageDialog->new
	  ($self,
	   __x("{pkg} {app} version {ver}",
	       pkg => $EekBoek::PACKAGE,
	       app => "WxShell",
	       ver => $EekBoek::VERSION)."\n".
	   "Copyright 2007-$year Squirrel Consultancy\n\n".
	   __x("Written by {author}",
	       author => "Johan Vromans")."\n".
	   "<jvromans\@squirrel.nl>\n".
	   "http://www.squirrel.nl\n".
	   __x("Support: {url}",
	       url => "http://www.eekboek.nl/support.html")."\n".
	   "\n".
	   __x("GUI design with {wxglade}",
	       wxglade => "wxGlade, http://wxglade.sourceforge.net")."\n\n".
	   __x("{pkg} version {ver}",
	       pkg => "Perl",
	       ver => sprintf("%vd",$^V))."\n".
	   __x("{pkg} version {ver}",
	       pkg => "WxPerl",
	       ver => $Wx::VERSION)."\n".
	   __x("{pkg} version {ver}",
	       pkg => "wxWidgets",
	       ver => Wx::wxVERSION)."\n".
	   ( $Cava::Packager::PACKAGED
	     ? __x("{pkg} version {ver}",
		   pkg => "CAVA Packager",
		   ver => $Cava::Packager::VERSION)."\n"
	     : () ),
	   __x("About {pkg} {app}",
	       pkg => $EekBoek::PACKAGE,
	       app => "WxShell"),
	   wxOK|wxICON_INFORMATION,
	   wxDefaultPosition);
	$md->ShowModal;
	$md->Destroy;

# end wxGlade
}


sub OnClear {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnClear <event_handler>

	$self->{t_output}->SetValue("");

# end wxGlade
}

sub OnPrefs {
    my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnPrefs <event_handler>
    $self->{d_prefs} ||= EB::Wx::Shell::PreferencesDialog->new($self, -1, "Preferences");
    for ( keys( %$prefctl ) ) {
	if ( exists $self->{d_prefs}->{"cx_$_"} ) {
	    $self->{d_prefs}->{"cx_$_"}->SetValue( $self->{"prefs_$_"} );
	}
	elsif ( exists $self->{d_prefs}->{"spin_$_"} ) {
	    $self->{d_prefs}->{"spin_$_"}->SetValue( $self->{"prefs_$_"} );
	}
    }
    my $ret = $self->{d_prefs}->ShowModal;
    if ( $ret == wxID_OK ) {
	for ( keys( %$prefctl ) ) {
	    if ( exists $self->{d_prefs}->{"cx_$_"} ) {
		$self->{"prefs_$_"} = $self->{d_prefs}->{"cx_$_"}->GetValue;
	    }
	    elsif ( exists $self->{d_prefs}->{"spin_$_"} ) {
		$self->{"prefs_$_"} = $self->{d_prefs}->{"spin_$_"}->GetValue;
	    }
	}
    }
# end wxGlade
}


sub FillHistory {
    my ($self, $histfile) = @_;
    $self->{_histfile} = $histfile;
    $self->{_cmd} = [];
    $self->{_cmdptr} = 0;
    if ( -s $histfile ) {
	my $fh;
	return unless open($fh, "<:encoding(utf-8)", $histfile);
	my $prev = '';
	while ( <$fh> ) {
	    chomp;
	    next if $_ eq $prev;
	    $self->PutOnHistory($_);
	    $prev = $_;
	}
	close($fh);
    }
    $self->{_cmdinit} = $self->{_cmdptr} = $#{$self->{_cmd}} + 1;
}

sub GetPreferences {
    my ( $self ) = @_;
    my $conf = Wx::ConfigBase::Get;
    for ( keys( %$prefctl ) ) {
	$self->{"prefs_$_"} = $conf->ReadInt( "preferences/$_", $prefctl->{$_} );
    }
}

sub SaveHistory {
    my $self = shift;
    my $fh;
    my $histfile = $self->{_histfile};

    $self->{_cmdinit} = $self->{_cmdptr} - $self->{prefs_histlines};
    $self->{_cmdinit} = 0 if $self->{_cmdinit} < 0;

    return unless open($fh, ">:encoding(utf-8)", $histfile);
    while ( $self->{_cmdinit} < $self->{_cmdptr} ) {
	print { $fh } ($self->{_cmd}->[$self->{_cmdinit}], "\n");
	$self->{_cmdinit}++;
    }
    close($fh);
}

sub SavePreferences {
    my ( $self ) = @_;
    my $conf = Wx::ConfigBase::Get;
    for ( keys( %$prefctl ) ) {
	$conf->WriteInt( "preferences/$_", $self->{"prefs_$_"} );
    }
}

sub OnMenuBal {
	my ($self, $event, $sub) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnMenuBal <event_handler>

	if ( defined $sub && $sub >= 0 ) {
	    $self->{_proc}->WriteProcess("balans --verdicht --detail=$sub --gen-wxhtml\n");
	}
	else {
	    $self->{_proc}->WriteProcess("balans --gen-wxhtml\n");
	}
# end wxGlade
}


sub OnMenuRes {
	my ($self, $event, $sub) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnMenuRes <event_handler>

	if ( defined $sub && $sub >= 0 ) {
	    $self->{_proc}->WriteProcess("result --verdicht --detail=$sub --gen-wxhtml\n");
	}
	else {
	    $self->{_proc}->WriteProcess("result --gen-wxhtml\n");
	}
# end wxGlade
}


sub OnMenuAP {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnMenuAP <event_handler>

	$self->{_proc}->WriteProcess("crediteuren --gen-wxhtml\n");

# end wxGlade
}


sub OnMenuAR {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnMenuAR <event_handler>

	$self->{_proc}->WriteProcess("debiteuren --gen-wxhtml\n");

# end wxGlade
}

sub OnMenuVAT {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnMenuAR <event_handler>

	$self->{_proc}->WriteProcess("btwaangifte --gen-wxhtml\n");

# end wxGlade
}


sub OnMenuUns {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnMenuUns <event_handler>

	$self->{_proc}->WriteProcess("openstaand --gen-wxhtml\n");

# end wxGlade
}


sub OnTrial {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnTrial <event_handler>

	$self->{_proc}->WriteProcess("proefensaldibalans --gen-wxhtml\n");

# end wxGlade
}


sub OnJournal {
	my ($self, $event) = @_;
# wxGlade: EB::Wx::Shell::MainFrame::OnJournal <event_handler>

	$self->{_proc}->WriteProcess("journaal --gen-wxhtml\n");

# end wxGlade
}

#### Callbacks from HTML links

sub _HTMLCallBack {
    my ($self, $command, $args) = @_;

    my $cmd = $command;
    $cmd .= " " . delete($args->{select});

    while ( my($k,$v) = each( %$args ) ) {
	$cmd .= " --$k=$v";
    }
    $cmd .= " --gen-wxhtml";

    $self->{_proc}->WriteProcess($cmd."\n");
}

sub ShowRJnl { shift->_HTMLCallBack( "journaal",    @_ ) }
sub ShowRGbk { shift->_HTMLCallBack( "grootboek",   @_ ) }
sub ShowRCrd { shift->_HTMLCallBack( "crediteuren", @_ ) }
sub ShowRDeb { shift->_HTMLCallBack( "debiteuren",  @_ ) }

# end of class EB::Wx::Shell::MainFrame

1;

