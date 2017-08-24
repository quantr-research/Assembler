grammar Assembler;

NUMBER				:	'0x'? [0-9]+;
STRING				:	'"' ~["]* '"';
REG					:	'edx';

LINE_COMMENT		:	';' ~[\r\n]*;
SECTION_NAME		:	'.' [a-zA-Z] [a-zA-Z0-9]+;
IDENTIFIER			:	[a-zA-Z] [a-zA-Z0-9]+;

LABEL_POSTFIX		:	'equ' ~[;]*;


WS					:	[ \t]+;
NL					:	'\r'? '\n';


assemble	:	lines
			|	EOF
			;

lines		:	(WS? line NL*)*
			;

line		:	label? statement WS? comment*
			|	label? comment
			|	WS
			;

statement	:	marco
			|	code
			|	data
			|	function
			|	MISSING_STATEMENT
			;

comment		:	LINE_COMMENT
			;

marco		:	'SECTION' WS SECTION_NAME
			|	label
			;

label		:	WS? IDENTIFIER ':' WS? LABEL_POSTFIX?
			;

code		:	'mov' WS REG ',' REG
			|	'int' WS REG ',' REG
			;

data		:	'db' WS STRING ',' NUMBER
			;

function	:	'global' WS IDENTIFIER
			;