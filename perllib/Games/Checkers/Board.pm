# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

use strict;

package Games::Checkers::Board;

use Games::Checkers::BoardConstants;
use Games::Checkers::Constants;
use Games::Checkers::IteratorConstants;

sub new ($;$) {
	my $class = shift;
	my $board = shift;

	my $self = {
		occupMap => 0xFFF00FFF,
		colorMap => 0xFFFF0000,
		pieceMap => 0x00000000,
	};
	bless $self, $class;
	$self->copy($board) if defined $board;
	return $self;
}

sub occup ($$) {
	my $self = shift;
	my $loc = shift;
	return !!($self->{occupMap} & (1 << $loc));
}

sub color ($$) {
	my $self = shift;
	my $loc = shift;
	return !!($self->{colorMap} & (1 << $loc));
}

sub piece ($$) {
	my $self = shift;
	my $loc = shift;
	return !!($self->{pieceMap} & (1 << $loc));
}

sub white ($$) {
	my $self = shift;
	my $loc = shift;
	return $self->occup($loc) && $self->color($loc) == White;
}

sub black ($$) {
	my $self = shift;
	my $loc = shift;
	return $self->occup($loc) && $self->color($loc) == Black;
}

sub copy ($$) {
	my $self = shift;
	my $board = shift;

	$self->{$_} = $board->{$_} for qw(occupMap colorMap pieceMap);
	return $self;
}

sub clrAll ($) {
	my $self = shift;
	$self->{occupMap} = 0;
}

sub clr ($$) {
	my $self = shift;
	my $loc = shift;
	$self->{occupMap} &= ~(1 << $loc);
}

sub set ($$$$) {
	my $self = shift;
	my ($loc, $color, $type) = @_;
	$self->{occupMap} |= (1 << $loc);
	($self->{colorMap} &= ~(1 << $loc)) |= ((1 << $loc) * $color);
	($self->{pieceMap} &= ~(1 << $loc)) |= ((1 << $loc) * $type);
}


sub getCost ($$) {
	my $self = shift;
	my $turn = shift;

	# Count white & black figures
	my ($whitePawns, $whiteKings, $blackPawns, $blackKings) = (0) x 4;

	my $whitesIterator = new Games::Checkers::FigureIterator($self, White);
	while ($whitesIterator->left) {
		my $loc = $whitesIterator->next;
		$self->piece($loc) == Pawn? $whitePawns++: $whiteKings++;
	}

	my $blacksIterator = new Games::Checkers::FigureIterator($self, Black);
	while ($blacksIterator->left) {
		my $loc = $blacksIterator->next;
		$self->piece($loc) == Pawn? $blackPawns++: $blackKings++;
	}

	return -1e8 if $whitePawns + $whiteKings == 0;
	return +1e8 if $blackPawns + $blackKings == 0;

	return
		+ $whitePawns*100
		+ $whiteKings*600
		- $blackPawns*100
		- $blackKings*600
		+ ($turn == White? 1: -1);
}

sub transform ($) {
	my $self = shift;
	my $move = shift;

	my $src = $move->source;
	my $dst = $move->destin(0);
	my $beat = $move->isBeat;
	my $color = $self->color($src);
	my $piece = $self->piece($src);
	for (my $n = 0; $dst != NL; $src = $dst, $dst = $move->destin(++$n)) {
		$self->clr($src);
		$self->set($dst, $color, $piece);
		$self->clr($self->figureBetween($src, $dst)) if $beat;
		# convert to king if needed
		if (convertType->[$color][$piece] & (1 << $dst)) {
			$self->{pieceMap} ^= (1 << $dst);
			$piece ^= 1;
		}
	}
}

sub canPieceStep ($$;$) {
	my $self = shift;
	my $loc = shift;
	my $locd = shift;
	$locd = NL unless defined $locd;

	if (!$self->occup($loc)) {
		warn("Internal error in canPieceStep, loc=$loc is not occupied");
		&DIE_WITH_STACK();
		return No;
	}
	my $color = $self->color($loc);
	my $stepDst = $self->piece($loc) == Pawn?
		pawnStepIterator: kingStepIterator;
	$stepDst->init($loc, $color);
	while ($stepDst->left) {
		my $loc2 = $stepDst->next;
		next if $locd != NL && $locd != $loc2;
		next if $self->figureBetween($loc, $loc2) != NL;
		return Yes unless $self->occup($loc2);
	}
	return No;
}

sub canPieceBeat ($$;$) {
	my $self = shift;
	my $loc = shift;
	my $locd = shift;
	$locd = NL unless defined $locd;

	if (!$self->occup($loc)) {
		warn("Internal error in canPieceBeat, loc=$loc is not occupied");
		&DIE_WITH_STACK();
		return No;
	}
	my $color = $self->color($loc);
	my $beatDst = $self->piece($loc) == Pawn?
		pawnBeatIterator: kingBeatIterator;
	$beatDst->init($loc, $color);
	while ($beatDst->left) {
		my $loc2 = $beatDst->next;
		next if $locd != NL && $locd != $loc2;
		my $loc1 = $self->figureBetween($loc, $loc2);
		next if $loc1 == NL || $loc1 == ML;
		return Yes unless $self->occup($loc2) ||
			!$self->occup($loc1) || $self->color($loc1) == $color;
	}
	return No;
}

sub canColorStep ($$) {
	my $self = shift;
	my $color = shift;
	my $iterator = Games::Checkers::FigureIterator->new($self, $color);
	while ($iterator->left) {
		return Yes if $self->canPieceStep($iterator->next);
	}
	return No;
}

sub canColorBeat ($$) {
	my $self = shift;
	my $color = shift;
	my $iterator = Games::Checkers::FigureIterator->new($self, $color);
	while ($iterator->left) {
		return Yes if $self->canPieceBeat($iterator->next);
	}
	return No;
}

sub canColorMove ($$) {
	my $self = shift;
	my $color = shift;
	return $self->canColorBeat($color) || $self->canColorStep($color);
}

sub figureBetween ($$$) {
	my $self = shift;
	my $src = shift;
	my $dst = shift;

	for (my $drc = 0; $drc < DIRECTION_NUM; $drc++) {
		my $figures = 0;
		my $figure = NL;
		for (my $loc = locDirections->[$src][$drc]; $loc != NL; $loc = locDirections->[$loc][$drc]) {
			if ($loc == $dst) {
				return $figures > 1? ML: $figures == 1? $figure: NL;
			}
			if ($self->occup($loc)) {
				$figure = $loc;
				$figures++;
			}
		}
	}
	return NL;
}

#
#   +-------------------------------+
# 8 |   |:@:|   |:@:|   |:@:|   |:@:|
#   |---+---+---+---+---+---+---+---|
# 7 |:@:|   |:@:|   |:@:|   |:@:|   |
#   |---+---+---+---+---+---+---+---|
# 6 |   |:@:|   |:@:|   |:@:|   |:@:|
#   |---+---+---+---+---+---+---+---|
# 5 |:::|   |:::|   |:::|   |:::|   |
#   |---+---+---+---+---+---+---+---|
# 4 |   |:::|   |:::|   |:::|   |:::|
#   |---+---+---+---+---+---+---+---|
# 3 |:O:|   |:O:|   |:O:|   |:O:|   |
#   |---+---+---+---+---+---+---+---|
# 2 |   |:O:|   |:O:|   |:O:|   |:O:|
#   |---+---+---+---+---+---+---+---|
# 1 |:O:|   |:O:|   |:O:|   |:O:|   |
#   +-------------------------------+
#     a   b   c   d   e   f   g   h  
#

sub dump ($;$) {
	my $self = shift;
	my $prefix = shift || "";
	$prefix = "    " x $prefix if $prefix =~ /^\d+$/;

	my $charSets = [
		{
			tlc => "+",
			trc => "+",
			blc => "+",
			brc => "+",
			vcl => "|",
			vll => "|",
			vrl => "|",
			hcl => "-",
			htl => "-",
			hbl => "-",
			ccl => "+",
			bbs => "",
			bbe => "",
			bbf => ":",
			wbf => " ",
		},
		{
			tlc => "\016l\017",
			trc => "\016k\017",
			blc => "\016m\017",
			brc => "\016j\017",
			vcl => "\016x\017",
			vll => "\016t\017",
			vrl => "\016u\017",
			hcl => "\016q\017",
			htl => "\016w\017",
			hbl => "\016v\017",
			ccl => "\016n\017",
			bbs => "\e[0;7m",
			bbe => "\e[0m",
			bbf => " ",
			wbf => " ",
			# ~ a
		},
	];
	my %ch = %{$charSets->[$ENV{DUMB_CHARS}? 0: 1]};

	my $str = "";

	$str .= "\n";
	$str .= "  ". $ch{tlc}. ("$ch{hcl}$ch{hcl}$ch{hcl}$ch{htl}" x 7). "$ch{hcl}$ch{hcl}$ch{hcl}$ch{trc}\n";
	for (my $i = 0; $i < 8; $i++) {
		$str .= (8 - $i) . " $ch{vcl}";
		for (my $j = 0; $j < 8; $j++) {
			my $isUsed = ($i + $j) % 2;
			if (($i + $j) % 2) {
				my $loc = (7 - $i) * 4 + int($j / 2);
				my $ch0 = $ch{bbf};
				my $isKing = $self->piece($loc) == King;
				$ch0 = $self->white($loc)? $isKing? "8": "O": $isKing? "&": "@"
					if $self->occup($loc);
				$ch0 = $self->white($loc)? "\e[1m$ch0\e[0m": "\e[4m$ch0\e[0m"
					if $self->occup($loc);
				$str .= "$ch{bbs}$ch{bbf}$ch0$ch{bbs}$ch{bbf}$ch{bbe}";
			} else {
				$str .= $ch{wbf} x 3;
			}
			$str .= $ch{vcl};
		}
		$str .= "\n";
		$str .= "  ". $ch{vll}. ("$ch{hcl}$ch{hcl}$ch{hcl}$ch{ccl}" x 7). "$ch{hcl}$ch{hcl}$ch{hcl}$ch{vrl}\n" if $i != 7;
	}
	$str .= "  ". $ch{blc}. ("$ch{hcl}$ch{hcl}$ch{hcl}$ch{hbl}" x 7). "$ch{hcl}$ch{hcl}$ch{hcl}$ch{brc}\n";
	$str .= "    a   b   c   d   e   f   g   h  \n";
	$str .= "\n";

	$str =~ s/^/$prefix/gm;
	return $str;
}

1;
