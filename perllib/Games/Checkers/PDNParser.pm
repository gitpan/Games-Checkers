# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

use strict;

package Games::Checkers::PDNParser;

use Games::Checkers::LocationConversions;
use IO::File;

sub new ($$) {
	my $class = shift;
	my $fileName = shift;

	$fileName .= ".pdn.gz" if -r "$fileName.pdn.gz";
	$fileName .= ".pdn" if -r "$fileName.pdn";
	$fileName .= ".gz" if -r "$fileName.gz";
	my $fileToOpen = $fileName =~ /\.gz$/? "zcat $fileName |": $fileName;
	my $fd = new IO::File $fileToOpen;
	die "Can't open PDN for reading ($fileName)\n" unless $fd;

	my $self = { fn => $fileName, fd => $fd, lineno => 0 };
	bless $self, $class;
	return $self;
}

sub errorPrefix {
	my $self = shift;
	"Error parsing $self->{fn}, line $self->{lineno}, corrupted record:\n";
}

sub nextRecord ($) {
	my $self = shift;

	my $recordValues = {};

	my $line;
	my $notEnd = 0;
	while ($line = $self->{fd}->getline) {
		$self->{lineno}++;
		next if $line =~ /^\s*(([#;]|{.*}|\(.*\))\s*)?$/;
		$notEnd = 1;
		if ($line =~ /\[(\w+)\s+"?(.*?)"?\]/) {
			$recordValues->{$1} = $2;
			next;
		}
		last;
	}
	return undef unless $notEnd;

	my $result = $recordValues->{Result};
	die $self->errorPrefix . "\tNon empty named value 'Result' is missing\n"
		unless $result;
	my $lineno = $self->{lineno};

	my $moveString = "";
	while (!$moveString || ($line = $self->{fd}->getline) && $self->{lineno}++) {
		$line =~ s/[\r\n]+$/ /;
		$moveString .= $line;
		last if $line =~ /$result/;

		# tolerate some broken PDNs without trailing result separator
		my $nextChar = $self->{fd}->getc;
		$self->{fd}->ungetc(ord($nextChar));
		last if $nextChar eq "[";
	}

	# tolerate some broken PDNs without result separator
#	die $self->errorPrefix . "\tSeparator ($result) is not found from line $lineno\n"
#		unless $line;

	$moveString =~ s/\b$result\b.*//;
	$moveString =~ s/{[^}]*}//g;  # remove comments
	$moveString =~ s/\([^\)]*(\)[^(]*)?\)//g;  # remove comments
	$moveString =~ s/([x:*-])\s+(\d|\w)/$1$2/gi;  # remove alignment spaces
	my @moveVergeStrings = split(/(?:\s+|\d+\.\s*)+/, $moveString);
	shift @moveVergeStrings while @moveVergeStrings && !$moveVergeStrings[0];

	my @moveVergeTrios = map {
		/^((\d+)|\w\d)([x:*-])((\d+)|\w\d)$/i
			|| die $self->errorPrefix . "\tIncorrect move notation ($_)\n";
		[
			$3 eq "-"? 0: 1,
			defined $2? numToLocation($1): strToLocation($1),
			defined $5? numToLocation($4): strToLocation($4),
		]
	} @moveVergeStrings;

	return [ \@moveVergeTrios, $recordValues ];
}

1;
