# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

package Games::Checkers::LocationConversions;

sub locationToArr ($) {
	my ($loc) = @_;
	return (int($loc % 4) * 2 + int(($loc / 4) % 2) + 1, int($loc / 4) + 1);
}

sub arrToLocation ($$) {
	my ($x, $y) = @_;
	return int((($x - 1) % 8) / 2) + ($y - 1) * 4;
}

sub locationToStr ($) {
	my ($loc) = @_;
	my @c = locationToArr($loc);
	return chr(ord('a') + $c[0] - 1) . $c[1];
}

sub strToLocation ($) {
	my ($str) = @_;
	$str =~ /^(\w)(\d)$/ || die "Invalid board coordinate string ($str)\n";
	return arrToLocation(ord($1) - ord('a') + 1, $2);
}

sub locationToNum ($) {
	my ($loc) = @_;
	return (int($loc / 4)) * 4 + 4 - $loc % 4;
#	return $ENV{ITALIAN_BOARD_NOTATION}? 32 - $loc: $loc + 1;
}

sub numToLocation ($) {
	my ($num) = @_;
	return (int(($num - 1) / 4)) * 4 + 3 - ($num - 1) % 4;
#	return $ENV{ITALIAN_BOARD_NOTATION}? 32 - $num: $num - 1;
}

use base 'Exporter';
@EXPORT = qw(
	locationToArr arrToLocation
	locationToStr strToLocation
	locationToNum numToLocation
);

1;
