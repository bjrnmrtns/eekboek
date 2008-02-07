# WxHtml.pm -- Reporter backend for WxHtmlWindow
# RCS Info        : $Id: WxHtml.pm,v 1.2 2008/02/07 11:39:04 jv Exp $
# Author          : Johan Vromans
# Created On      : Fri Mar  2 21:01:17 2007
# Last Modified By: Johan Vromans
# Last Modified On: Thu Feb  7 12:37:46 2008
# Update Count    : 48
# Status          : Unknown, Use with caution!

# WxHtmlWindow supports HTML, but to a limited extent. In particular,
# no CSS.
# For WxHtml we generate a simplified HTML, where the ornaments and
# decorations are handled in the HTML subset supported.

package main;

our $cfg;

package EB::Report::Reporter::WxHtml;

use strict;
use warnings;
use EB;

use base qw(EB::Report::Reporter);

################ API ################

sub new {
    my ($class, $opts) = @_;

    # This backend can collect the output in a scalar.
    my $o;
    $o = delete($opts->{output})
      if $opts->{output} && UNIVERSAL::isa($opts->{output}, 'SCALAR');

    my $self = $class->SUPER::new($opts->{STYLE}, $opts->{LAYOUT});
    $self->{overall_font_size} = $cfg->val(qw(wxhtml fontsize), "0");;

    $self->{_OUT} = $o if $o;

    return $self;
}

my $html;

sub start {
    my ($self, @args) = @_;
    eval {
	require HTML::Entities;
    };
    $html = $@ ? \&__html : \&_html;
    $self->SUPER::start(@args);
}

sub finish {
    my ($self) = @_;
    $self->SUPER::finish();
    $self->_print("</table>\n");
    $self->_print("</font>\n") if $self->{overall_font_size};
    $self->_print("</body>\n",
		  "</html>\n");
    $self->_close;
}

sub add {
    my ($self, $data) = @_;

    my $style = delete($data->{_style});

    $self->SUPER::add($data);

    return unless %$data;

    $self->_checkhdr;

    $self->_print("<tr>\n");

    my %style;
    if ( $style && (my $t = $self->_getstyle($style)) ) {
	%style = %$t;
    }

    foreach my $col ( @{$self->{_fields}} ) {
	my $fname = $col->{name};
	my $value = defined($data->{$fname}) ? $data->{$fname} : "";
	my $align = $col->{align} eq "<"
	            ? "left"
	            : $col->{align} eq ">"
	              ? "right"
		      : "center";
	$align = " align=\"$align\"" if $align;

	# Examine style mods.
	my ($font, $weight, $italic, $indent);
	if ( $style ) {
	    if ( my $t = $self->_getstyle($style, $fname) ) {
		$t = { %style, %$t };
		my $colour = $t->{colour} || $t->{color} || "";
		$colour = " color=\"$colour\"" if $colour;
		my $size = defined($t->{size}) ? " size=\"$t->{size}\"" : "";
		$weight = [ "<b>", "</b>" ]
		  if defined($t->{weight}) && $t->{weight} eq "bold";
		$italic = [ "<i>", "</i>" ] if $t->{italic};
		$font = [ "<font$colour$size>", "</font>" ]
		  if $colour || $size;
		$align = " align=\"$t->{align}\"" if $t->{align};
		$indent = "&nbsp;" x (2 * $t->{indent}) if $t->{indent};
	    }
	}
	$self->_print("<td$align>",
			     $font ? $font->[0] : (),
			     $weight ? $weight->[0] : (),
			     $italic ? $italic->[0] : (),
			     $indent ? $indent : (),
			     $value eq "" ? "&nbsp;" : $html->($value),
			     $italic ? $italic->[1] : (),
			     $weight ? $weight->[1] : (),
			     $font ? $font->[1] : (),
			     "</td>\n");
    }

    $self->_print("</tr>\n");
}

################ Pseudo-Internal (used by Base class) ################

sub header {
    my ($self) = @_;

    my $ofs = $self->{overall_font_size};

    $self->_print
      ("<html>\n",
       "<head>\n",
       "<title>", $html->($self->{_title1}), "</title>\n",
       "</head>\n",
       "<body>\n",
       $ofs ? "<font size=\"$ofs\">\n" : (),
       "<p><b>", $html->($self->{_title1}), "</b><br>\n",
       $html->($self->{_title2}), "<br>\n",
       $html->($self->{_title3l}), "<br>\n",
       "&nbsp;</p>\n",
       $ofs ? "</font>\n" : (),
       $ofs ? "<font size=\"$ofs\">\n" : (),
       "<table border=\"1\" width=\"100%\">\n");

    $self->_print("<tr>\n");
    foreach ( @{$self->{_fields}} ) {
	$self->_print("<th align=\"",
		      $_->{align} eq "<"
		      ? "left"
		      : $_->{align} eq ">"
		        ? "right"
		        : "center",
		      "\">",
		      "<b>", $html->($_->{title}), "</b></th>\n");
    }
    $self->_print("</tr>\n");

}

################ Internal methods ################

sub _print {
    my $self = shift;
    if ( exists($self->{_OUT}) ) {
	${$self->{_OUT}} .= $_ foreach @_;
	return;
    }
    $self->{fh}->print(@_);
}

sub _close {
    my $self = shift;
    if ( exists($self->{_OUT}) ) {
	return;
    }
    $self->{fh}->close;
}

sub _html {
    HTML::Entities::encode(shift);
}

sub __html {
    my ($t) = @_;
    $t =~ s/&/&amp;/g;
    $t =~ s/</&lt;/g;
    $t =~ s/>/&gt;/g;
    $t =~ s/\240/&nbsp;/g;
    $t =~ s/\x{eb}/&euml;/g;	# for IVP.
    $t;
}

1;
