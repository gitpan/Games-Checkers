# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

package Games::Checkers::PlayerConstants;

# PlayerType
use Games::Checkers::DeclareConstant {
	User => 0,
	Comp => 1,
};

# MoveStatus
use Games::Checkers::DeclareConstant {
	MoveDone => 0,
	GameOver => 1,
	StopGame => 2,
};

1;
