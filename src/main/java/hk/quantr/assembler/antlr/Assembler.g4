grammar Assembler;

NL				:	'\r'? '\n';
ID				:	[a-zA-Z] [a-zA-Z0-9]+;
LINE_COMMENT	:	';' ~[\r\n]*;
WS				:	[ \t]+;

assemble	:	lines
			|	EOF
			;

lines		:	(WS* line NL*)*
			;

line		:	statement WS* comment*
			|	comment
			;

statement	:	ID+;

comment		:	LINE_COMMENT
			;
