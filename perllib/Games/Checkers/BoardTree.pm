# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

use strict;

package Games::Checkers::BoardTreeNode;

use base 'Games::Checkers::Board';

use Games::Checkers::Constants;
use Games::Checkers::MoveConstants;
use Games::Checkers::CreateMoveList;

use constant NO_COST => 1e9;
use constant EqualCostDeterminism => $ENV{EQUAL_COST_DETERMINISM};

my $stopped = No;
sub checkUserInteraction () {
	# no user interaction yet
	return Ok;
}

sub new ($$$) {
	my $class = shift;
	my $board = shift;
	my $move = shift;

	my $self = $class->SUPER::new($board);
	$self->{move} = $move;
	$self->{sons} = [];
   $self->{expanded} = 0;
	return $self;
}

#       o                                                    3  0
#       |                                                         white max
#       o-----------------------o                            2  1
#       |                       |                                 black min
#       o-------o-------o       o-------o-------o            1  2
#       |       |       |       |       |       |                 white max
#       o-o-o   o-o-o   o-o-o   o-o-o   o-o-o   o-o-o        0  3

sub expand ($$) {
	my $self = shift;
	my $color = shift;

	my $creatingMoves = Games::Checkers::CreateMoveList->new($self, $color);
   $self->{expanded} = 1;
	return $creatingMoves->{status};
}

sub unexpand ($) {
	my $self = shift;
	$_->unexpand foreach @{$self->{sons}};
	@{$self->{sons}} = ();
   $self->{expanded} = 0;
}

sub isBetterCost ($$$$) {
	my $self = shift;
	my $color = shift;
	my $cost1 = shift;
	my $cost2 = shift;

	return int(rand(2)) unless $cost1 != $cost2 || EqualCostDeterminism;

	my $max = ($cost1 > $cost2)? $cost1: $cost2;
	my $min = ($cost1 < $cost2)? $cost1: $cost2;
	my $best = ($color == ($Games::Checkers::giveAway? Black: White))? $max: $min;
	return $best == $cost1;
}

sub chooseBestSon ($$$$$) {
	my $self = shift;
	my $color = shift;
	my $level = shift;
	my $maxLevel = shift;

#	return undef if $stopped || checkUserInteraction() != Ok;

	my $bestNode = undef;
	my $bestCost = NO_COST;

	if ($level != 0) {
		# should use return value to determine actual thinking level
		$self->expand($color) unless $self->{expanded};

		foreach my $son (@{$self->{sons}}) {
			my ($deepNode, $deepCost) = $son->chooseBestSon(!$color, $level-1, $maxLevel);
         ($bestNode, $bestCost) = ($deepNode, $deepCost)
				if $bestCost == NO_COST || $self->isBetterCost($color, $deepCost, $bestCost);
		}

		$self->unexpand;
	}

	if (!defined $bestNode) {
      $bestNode = $self;
		$bestCost = $self->getCost($color);
	} elsif ($level == $maxLevel - 1) {
      $bestNode = $self;
	}

	return wantarray? ($bestNode, $bestCost): $bestNode;
}

package Games::Checkers::BoardTree;

use Games::Checkers::MoveConstants;
use Games::Checkers::BoardConstants;

sub new ($$$;$) {
	my $class = shift;
	my $board = shift;
	my $color = shift;
	my $level = shift || DEFAULT_LEVEL;

	my $self = {
		head => new Games::Checkers::BoardTreeNode($board, NO_MOVE),
		maxLevel => $level,
		realLevel => undef,
		color => $color,
	};

	return bless $self, $class;
}

sub chooseBestMove ($) {
	my $self = shift;

	my $maxLevel = $self->{maxLevel};
	my $son = $self->{head}->chooseBestSon($self->{color}, $maxLevel, $maxLevel);
#	foreach my $son0 (@{$self->{sons}}) {
#		next if defined $son && $son == $son0;
#		$son0->unexpand;
#	}
   return NO_MOVE unless $son;
	return $son->{move};
}

sub chooseRandomMove ($) {
	my $self = shift;

	$self->{head}->expand($self->{color});
	my $sons = $self->{head}->{sons};
	my $move = $sons->[int(rand(@$sons))]->{move};
	$self->{head}->unexpand;
	return $move;
}

1;
