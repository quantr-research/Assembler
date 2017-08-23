grammar Assembler;

NL	:	'\r'? '\n';
ID	:	[0-9]+;

assemble	: statements
			| EOF
			;

statements	:	(statement NL+)*
			;

statement	:	ID;