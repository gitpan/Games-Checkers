# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

use strict;

package Games::Checkers::MoveListNode;

use base 'Games::Checkers::Board';

sub new ($;$) {
	my $class = shift;
	my $board = shift;
	my $move = shift;

	my $self = $class->SUPER::new($board);
	$self->{move} = $move;
	return $self;
}

1;
