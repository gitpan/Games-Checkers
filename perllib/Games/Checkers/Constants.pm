# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

package Games::Checkers::Constants;

use Games::Checkers::DeclareConstant {
	Ok => 0,
	Err => 1,
	No => 0,
	Yes => 1,
	False => 0,
	True => 1,
	White => 0,
	Black => 1,
	Pawn => 0,
	King => 1,
	DIE_WITH_STACK => sub {
		for (my $i = 0; ; $i++) {
			my ($package, $filename, $line, $subroutine) = caller($i);
			die "\n" unless defined $package;
			$filename =~ s/.*\///;
		   $subroutine = (caller($i+1))[3] || "(main)";
			print "\t$filename, line $line, $subroutine\n";
		}
	},
};

1;
