#!/usr/bin/perl -w

use strict;
use FindBin;

BEGIN {
	my $libdir = "$FindBin::Bin/../perllib";
	eval qq(use lib "$libdir"); die $@ if $@;

	my @classes = map {
		s!^$libdir/!!; s!/!::!g; s!\.pm$!!g;
		$_;
	} "$libdir/Games/Checkers.pm", glob("$libdir/Games/Checkers/*.pm");

	eval qq(use Test::More tests => ) . (0 + @classes); die $@ if $@;

	use_ok($_) foreach @classes;
}
