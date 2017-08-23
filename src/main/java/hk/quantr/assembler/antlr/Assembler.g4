grammar Assembler;

NUMBER				:	'0x'? [0-9]+;
STRING				:	'"' ~["]* '"';

LINE_COMMENT		:	';' ~[\r\n]*;

SECTION_NAME		:	'.' [a-zA-Z] [a-zA-Z0-9]+;
LABEL_NAME			:	[a-zA-Z] [a-zA-Z0-9]+;
FUNCTION_NAME		:	[a-zA-Z] [a-zA-Z0-9]+;

LABEL_POSTFIX		:	'equ' ~[;]*;

OPERANDS			:	[a-zA-Z0-9,]+;
MISSING_STATEMENT	:	[a-zA-Z0-9]+;

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

label		:	WS? LABEL_NAME ':' WS? LABEL_POSTFIX?
			;

code		:	'mov' WS OPERANDS
			|	'int' WS NUMBER
			;

data		:	'db' WS ',' NUMBER
			;

function	:	'global' WS FUNCTION_NAME
			;