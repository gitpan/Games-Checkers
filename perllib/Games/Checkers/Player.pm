# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

use strict;

package Games::Checkers::Player;

use Games::Checkers::PlayerConstants;

# static method
sub create ($$$) {
	my ($type, $color, $level) = @_;
	my $class = "Games::Checkers::" . ($type == User? "User": "Comp") . "Player";
	return $class->new($color, $level);
}

sub new ($$$) {
	my $class = shift;
	my $color = shift;
	my $level = shift;

	my $self = {
		color => $color,
		level => $level,
		moveStatus => MoveDone,
	};
	return bless $self, $class;
}

sub do_move ($) { die __PACKAGE__ . ": pure virtual method is called"; }

1;
