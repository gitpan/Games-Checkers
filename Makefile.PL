use 5.005;

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => 'Games::Checkers',
	DISTNAME => 'Games-Checkers',
	dist => {
		# default CP 'ln' is buggy, it changes source file permissions
		DIST_CP => 'cp',
		TO_UNIX => 'ln -s russian $(DISTVNAME)/data/games/default && ln -s test.pdn $(DISTVNAME)/data/games/default/default.pdn',
	},
	EXE_FILES => [ glob("bin/*") ],
	PM => {
		map {
			my $t = $_; $t =~ s/^perllib\/Games\///;
			($_, '$(INST_LIBDIR)/' . $t)
		} "perllib/Games/Checkers.pm", glob("perllib/Games/Checkers/*.pm")
	},
	# this translation should not be needed, but MakeMaker is buggy again
	MAN3PODS => {
		'perllib/Games/Checkers.pm' => '$(INST_MAN3DIR)/Games::Checkers.3pm',
	},
	VERSION_FROM => 'perllib/Games/Checkers.pm',
	ABSTRACT_FROM => 'perllib/Games/Checkers.pm',
	AUTHOR => 'Mikhael Goikhman <migo@homemail.com>',
);
