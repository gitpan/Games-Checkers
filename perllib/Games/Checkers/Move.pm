# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

use strict;

package Games::Checkers::Move;

use Games::Checkers::BoardConstants;
use Games::Checkers::LocationConversions;

sub new ($$$$) {
	my $class = shift;
	my ($isBeat, $src, $dsts) = @_;

	die "Games::Checkers::Move constructor, third arg should be array"
		unless ref($dsts) eq 'ARRAY';
	die "No destinations in Move construction" unless $src == NL || @$dsts;
	my $self = [ $isBeat, $src, [@$dsts] ];

	bless $self, $class;
	return $self;
}

use constant NoMove => Games::Checkers::Move->new(0, NL, []);

sub numSteps ($) {
	my $self = shift;
	return scalar @{$self->[2]};
}

sub isBeat ($) {
	my $self = shift;
	return $self->[0];
}

sub source ($) {
	my $self = shift;
	return $self->[1];
}

sub destin ($$) {
	my $self = shift;
	my $num = shift;
	return $num < 0 || $num >= @{$self->[2]}? NL: $self->[2]->[$num];
}

sub clone ($) {
	my $self = shift;
	return Games::Checkers::Move->new(@$self);
}

sub dump ($) {
	my $self = shift;
	my $delim = $self->isBeat? ":": "-";
	my $str = locationToStr($self->source);
	for (my $i = 0; $i < $self->numSteps; $i++) {
		$str .= $delim . locationToStr($self->destin($i));
	}
	return $str;
}

1;
