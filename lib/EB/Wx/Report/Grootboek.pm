# generated by wxGlade 0.4cvs on Wed Aug  3 22:34:27 2005
# To get wxPerl visit http://wxPerl.sourceforge.net/

use Wx 0.15 qw[:allclasses];
use strict;
package RepGrootboek;

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

# begin wxGlade: RepGrootboek::new

	$style = wxDEFAULT_DIALOG_STYLE|wxRESIZE_BORDER|wxTHICK_FRAME 
		unless defined $style;

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );

	$self->__set_properties();
	$self->__do_layout();

# end wxGlade
	return $self;

}


sub __set_properties {
	my $self = shift;

# begin wxGlade: RepGrootboek::__set_properties

	$self->SetTitle("Grootboek");

# end wxGlade
}

sub __do_layout {
	my $self = shift;

# begin wxGlade: RepGrootboek::__do_layout

	$self->Layout();

# end wxGlade
}

# end of class RepGrootboek

1;

