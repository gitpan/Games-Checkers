# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

use strict;

package Games::Checkers::ExpandMoveList;

use base 'Games::Checkers::MoveLocationConstructor';
use Games::Checkers::Constants; 
use Games::Checkers::IteratorConstants;

sub new ($$$) {
	my $class = shift;
	my $board = shift;
	my $color = shift;
	my $self = $class->SUPER::new($board, $color);

	$self->{figureIterator} =
		new Games::Checkers::FigureIterator($board, $color);
	$self->{status} = Ok;
	return $self;
}

sub status ($) {
	my $self = shift;
	return $self->{status};
}

sub build ($) {
	my $self = shift;
	while ($self->{figureIterator}->left) {
		if ($self->source($self->{figureIterator}->next) == Ok) {
			$self->buildContinue;
			return if $self->{status} == Err;
		}
	}
}

sub buildContinue ($) {
	my $self = shift;

	my $iteratorClass = "Games::Checkers::";
	$iteratorClass .= (qw(PawnStepIterator PawnBeatIterator KingStepIterator KingBeatIterator))
		[($self->{piece} == King) * 2 + $self->{mustBeat}];
	my $ruleIterator = $iteratorClass->new($self->dst_1, $self->{color});

#	if (type == Pawn &&  must_beat) ruleIterator = &pawnBeatIterator;
#	if (type == Pawn && !must_beat) ruleIterator = &pawnStepIterator;
#	if (type == King &&  must_beat) ruleIterator = &kingBeatIterator;
#	if (type == King && !must_beat) ruleIterator = &kingStepIterator;
#	ruleIterator->init(dst_1(), color);
#	if (type == Pawn && !must_beat) ruleIterator = new PawnStepIterator(dst_1(), color);
#	if (type == Pawn &&  must_beat) ruleIterator = new PawnBeatIterator(dst_1(), color);
#	if (type == King && !must_beat) ruleIterator = new KingStepIterator(dst_1(), color);
#	if (type == King &&  must_beat) ruleIterator = new KingBeatIterator(dst_1(), color);
#	if (type == King &&  must_beat) ruleIterator = new ValidKingBeatIterator(dst_1(), color, *this);
#	unless ($ruleIterator)

	while ($ruleIterator->left) {
		next if $self->addDst($ruleIterator->next) == Err;
		if ($self->canCreateMove) {
			$self->{status} = $self->addMove;
		} else {
			$self->buildContinue;
		}
		$self->delDst;
		last if $self->{status} == Err;
	}
}

sub addMove ($) {
	my $self = shift;
	die "Pure virtual method is called";
}

1;
