# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

package Games::Checkers::IteratorConstants;

use Games::Checkers::Iterators;

use Games::Checkers::DeclareConstant {
	pawnStepIterator => Games::Checkers::Iterators::pawnStepIterator,
	pawnBeatIterator => Games::Checkers::Iterators::pawnBeatIterator,
	kingStepIterator => Games::Checkers::Iterators::kingStepIterator,
	kingBeatIterator => Games::Checkers::Iterators::kingBeatIterator,
};

1;
