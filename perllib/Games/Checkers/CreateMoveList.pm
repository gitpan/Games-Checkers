# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

use strict;

# ----------------------------------------------------------------------------

package Games::Checkers::CreateMoveList;

use base 'Games::Checkers::ExpandMoveList';

use Games::Checkers::Constants;
use Games::Checkers::MoveConstants;

sub new ($$$) {
	my $class = shift;
	my $boardTreeNode = shift;
	my $color = shift;
	my $self = $class->SUPER::new($boardTreeNode, $color);

	$self->{boardTreeNode} = $boardTreeNode;

	$self->build;
	return $self;
}

sub addMove ($) {
	my $self = shift;
	my $move = $self->createMove;
	return Err unless $move;  ### not needed
	die "Internal Error" if $move == NO_MOVE;
	my $newBoardTreeNode = Games::Checkers::BoardTreeNode->new($self, $move);
	return Err unless $newBoardTreeNode;  ### not needed
	push @{$self->{boardTreeNode}->{sons}}, $newBoardTreeNode;
	return Ok;
}

# ----------------------------------------------------------------------------

package Games::Checkers::CountMoveList;

use base 'Games::Checkers::ExpandMoveList';

use Games::Checkers::Constants;

sub new ($$$) {
	my $class = shift;
	my $board = shift;
	my $color = shift;
	my $self = $class->SUPER::new($board, $color);

	$self->{count} = 0;

	$self->build;
	return $self;
}

sub addMove ($) {
	my $self = shift;
	$self->{count}++;
	return Ok;
}

sub getCount ($) {
	my $self = shift;
	return $self->{status} == Ok? $self->{count}: 0;
}

# ----------------------------------------------------------------------------

package Games::Checkers::CreateUniqueMove;

use base 'Games::Checkers::ExpandMoveList';

use Games::Checkers::Constants;
use Games::Checkers::MoveConstants;

sub new ($$$) {
	my $class = shift;
	my $board = shift;
	my $color = shift;
	my $self = $class->SUPER::new($board, $color);

	$self->{move} = NO_MOVE;

	$self->build;
	return $self;
}

sub addMove ($) {
	my $self = shift;
	return Err if $self->{move} != NO_MOVE;
	$self->{move} = $self->createMove;
	return Ok;
}

sub getMove ($) {
	my $self = shift;
	return $self->{status} == Ok? $self->{move}: NO_MOVE;
}

# ----------------------------------------------------------------------------

package Games::Checkers::CreateVergeMove;

use base 'Games::Checkers::ExpandMoveList';

use Games::Checkers::Constants;
use Games::Checkers::MoveConstants;
use Games::Checkers::Move;

sub new ($$$$$$) {
	my $class = shift;
	my $board = shift;
	my $color = shift;
	my $self = $class->SUPER::new($board, $color);

	die "Not enough arguments in constructor" unless @_ >= 3;
	my $isBeat = $self->{isBeat} = shift;
	my $src = $self->{src0} = shift;
	my $dst = $self->{dst0} = shift;

	die "Bad verge move source location ($src): not occupied\n"
		unless $board->occup($src);
	die "Bad verge move source location ($src): incorrect color\n"
		unless $board->color($src) == $color;
	die "Bad verge move source location ($src): can't beat\n"
		unless !$isBeat || $board->canPieceBeat($src);
#	die "Bad verge move source location ($src): can't step\n"
#		unless $isBeat || $board->canPieceStep($src);

	if (!$isBeat) {
		if ($board->canPieceStep($src, $dst)) {
			$self->{move} = new Games::Checkers::Move($isBeat, $src, [$dst]);
			return $self;
		}
		# give it the last chance
		$board->canPieceBeat($src)? $isBeat = 1:
			die "Bad verge move ($src-$dst): can't step\n";
	}

	# support British rules
	if ($isBeat) {
		if ($board->canPieceBeat($src, $dst)) {
			$self->{move} = new Games::Checkers::Move($isBeat, $src, [$dst]);
			return $self;
		}
	}
	$self->{move} = NO_MOVE;

	$self->build;
	return $self;
}

sub addMove ($) {
	my $self = shift;

	return Err if !$self->{mustBeat};
	return Ok if $self->{src} != $self->{src0} || $self->dst_1 != $self->{dst0};

	return Err if $self->{move} != NO_MOVE;
	$self->{move} = $self->createMove;
	return Ok;
}

sub getMove ($) {
	my $self = shift;
	return $self->{status} == Ok? $self->{move}: NO_MOVE;
}

1;
