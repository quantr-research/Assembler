grammar Test;

STRING				:	'"' ~["]* '"';
NUMBER				:	'0x'? [0-9]+;

OPERANDS			:	[a-zA-Z0-9,]+;

WS					:	[ \t]+;
NL					:	'\r'? '\n';


assemble	:	'db' WS ',' number
			;

number		:	NUMBER
			;
