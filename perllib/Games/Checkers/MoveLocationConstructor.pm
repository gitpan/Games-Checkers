# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

use strict;

package Games::Checkers::MoveLocationConstructor;

use base 'Games::Checkers::Board';
use Games::Checkers::Constants;
use Games::Checkers::BoardConstants;
use Games::Checkers::MoveConstants;

use constant MAX_MOVE_JUMP_NUM => 9;

sub new ($$$) {
	my $class = shift;
	my $board = shift;
	my $color = shift;

	my $self = $class->SUPER::new($board);
	my $fields = {
		color => $color,
		destin => [],
		src => NL,
		piece => 0,
		mustBeat => $board->canColorBeat($color),
		origBoard => $board,
	};
	$self->{$_} = $fields->{$_} foreach keys %$fields;
	return $self;
}
	
sub init ($) {
	my $self = shift;
	$self->{destin} = [];
	$self->{src} = NL;
	$self->copy($self->{origBoard});
}

sub source ($$) {
	my $self = shift;
	my $loc = shift;
	$self->init;
	return Err if $loc == NL || !$self->occup($loc) || $self->color($loc) != $self->{color};
	return Err if $self->{mustBeat} && !$self->canPieceBeat($loc) || !$self->{mustBeat} && !$self->canPieceStep($loc);
	$self->{piece} = $self->piece($self->{src} = $loc);
	return Ok;
}

sub addDst ($$) {
	my $self = shift;
	my $dst = shift;
	return Err if $self->{src} == NL || @{$self->{destin}} == MAX_MOVE_JUMP_NUM-1;
	if ($self->{mustBeat}) {
		die "Internal" unless $self->occup($self->dst_1);
		return Err unless $self->canPieceBeat($self->dst_1, $dst);
	} else {
		return Err if @{$self->{destin}} > 0;
		return Err unless $self->canPieceStep($self->{src}, $dst);
	}
	push @{$self->{destin}}, $dst;
	$self->transformOne;
	return Ok;
}

sub delDst ($) {
	my $self = shift;
	return NL if $self->{src} == NL || @{$self->{destin}} == 0;
	my $dst = pop @{$self->{destin}};
	$self->transformAll;
	return $dst;
}

sub canCreateMove ($) {
	my $self = shift;
	return $self->{mustBeat} && @{$self->{destin}} > 0
		&& $self->canPieceBeat($self->dst_1) == No
		|| !$self->{mustBeat} && @{$self->{destin}} == 1;
}

sub createMove ($) {
	my $self = shift;
	return NO_MOVE	if $self->{src} == NL
		|| $self->{mustBeat} && @{$self->{destin}} < 1
		|| !$self->{mustBeat} && @{$self->{destin}} != 1;
	return new Games::Checkers::Move(
		$self->{mustBeat}, $self->{src}, $self->{destin});
}

sub transformOne ($) {
	my $self = shift;
	my $src = $self->dst_2;
	my $dst = $self->dst_1;
	$self->clr($src);
	$self->set($dst, $self->{color}, $self->{piece});
	$self->clr($self->figureBetween($src, $dst)) if $self->{mustBeat};
	if (convertType->[$self->{color}][$self->{piece}] & (1 << $dst)) {
		$self->{pieceMap} ^= (1 << $dst);
		$self->{piece} ^= 1;
	}
}

sub transformAll ($) {
	my $self = shift;
	$self->copy($self->{origBoard});
	return if $self->{src} == NL || @{$self->{destin}} == 0;
	$self->{piece} = $self->piece($self->{src});
	my $destin = $self->{destin};
	$self->{destin} = [];
	while (@$destin) {
		push @{$self->{destin}}, shift @$destin;
		$self->transformOne;
	}
}

sub dst_1 ($) {
	my $self = shift;
	return @{$self->{destin}} == 0? $self->{src}: $self->{destin}->[-1];
}

sub dst_2 ($) {
	my $self = shift;
	return @{$self->{destin}} == 1? $self->{src}: $self->{destin}->[-2];
}

1;
