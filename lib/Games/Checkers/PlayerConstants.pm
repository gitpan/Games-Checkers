# Games::Checkers, Copyright (C) 1996-2012 Mikhael Goikhman, migo@cpan.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
