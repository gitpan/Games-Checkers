# Games::Checkers, Copyright (C) 1996-2004 Mikhael Goikhman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

package Games::Checkers::DeclareConstant;

## This is a general purpose module, kind of the next level of "use constant;".

# keys are package names, values are hash of constants for the package
use vars qw($registered);
$registered = {};

sub import ($;$$) {
   my $caller = caller;
	unless (exists $registered->{$caller}) {
		$registered->{$caller} = {};
		*{"${caller}::import"} = sub ($) {
			my $caller2 = caller;
			while (my ($name, $value) = each %{$registered->{$caller}}) {
				local $^W = 0;  # 5.005 still produces redefined warnings...
				eval "*${caller2}::$name = sub () { \$value }";
				die $@ if $@;
			}
		}
	}
	shift;
	my $constants = shift || return;
	$constants = { $constants => shift } unless ref($constants) eq 'HASH';
	$registered->{$caller}->{$_} = $constants->{$_} foreach keys %$constants;
}

1;

__END__


use strict;

package ABC;       
use Games::Checkers::DeclareConstant { a1 => "Checkers", a2 => ':' };
use Games::Checkers::DeclareConstant { a3 => "Games" };
package Real;
ABC->import;
print "Expected: Games::Checkers, real: ", a3(), a2(), a2(), a1(), "\n";

package World;  
use vars '@ISA';
@ISA = ('Real');
ABC->import;
print "Expected: Games::Checkers, real: ", a3(), a2(), a2(), a1(), "\n";
print "Expected: Games::Checkers, real: ", a3, a2, a2, a1, "\n";







use strict;

package Real;
use ABC;
print "Expected: Games::Checkers, real: ", a3(), a2(), a2(), a1(), "\n";

package World;
use vars '@ISA';
@ISA = ('Real');
use ABC;
print "Expected: Games::Checkers, real: ", a3(), a2(), a2(), a1(), "\n";
print "Expected: Games::Checkers, real: ", a3, a2, a2, a1, "\n";

sub abc {
	if (NL > 30) { print "NL\n"; }
}
abc();