/*	$Id$ */

TACTIC ForwardCutwithSubstSel(n,Rule) IS
	SEQ	cut 
		(WHEN	(LETSUBSTSEL _A Rule (WITHSUBSTSEL hyp))
				(JAPE (fail(please text-select one or more instances of a sub-formula)))
		)

TACTIC "abstraction-I tac" IS FSSOB ForwardCutwithSubstSel 0 "abstraction-I"

TACTIC "abstraction-E tac" IS FOBSS ForwardCut 0 "abstraction-E"
TACTIC "�-E tac" IS FOB ForwardCut 1 "�-E"

MENU SetOps IS
	ENTRY "abstraction-I" IS "abstraction-I tac"
	ENTRY "=-I"
	ENTRY "�-I(c)"
	ENTRY "�-I(<c,d>)"
	ENTRY "�-I(L)" IS FOB ForwardCut 0 "�-I(L)"
	ENTRY "�-I(R)" IS FOB ForwardCut 0 "�-I(R)"
	ENTRY "�-I"
	ENTRY "(-)-I"
	ENTRY "�-I" IS FOB ForwardCut 0 "�-I"
	
	SEPARATOR
	
	ENTRY "abstraction-E" IS "abstraction-E tac"
	ENTRY "�-E" IS "�-E tac"
	ENTRY "=-E(L)" IS FOB ForwardCut 0 "=-E(L)"
	ENTRY "=-E(R)" IS FOB ForwardCut 0 "=-E(R)"
	ENTRY "�-E" IS FOB ForwardUncut 0 "�-E"
	ENTRY "�-E(L)" IS FOB ForwardCut 0 "�-E(L)"
	ENTRY "�-E(R)" IS FOB ForwardCut 0 "�-E(R)"
	ENTRY "(-)-E(L)" IS FOB ForwardCut 0 "(-)-E(L)"
	ENTRY "(-)-E(R)" IS FOB ForwardCut 0 "(-)-E(R)"
	ENTRY "�-E" IS FOB ForwardCut 0 "�-E"
	
	SEPARATOR
	
	ENTRY "�-E" IS FOB ForwardCut 0 "�-E"
	ENTRY "A�U"
END

TACTICPANEL "Definitions" IS
	RULE IS A��B � �(A�B)
	RULE IS � � {}
	RULE (OBJECT x) IS EQ � {x|x=x}
	RULE (OBJECT x) IS {A} � {x|x=A}
	RULE (OBJECT x) IS {A,B} � {x|x=A�x=B}
	RULE (OBJECT x) IS {A,B,C} � {x|x=A�x=B�x=C}
	RULE (OBJECT x) IS {A,B,C,D} � {x|x=A�x=B�x=C�x=D}
	RULE (OBJECT y) IS A�B � (�y.y�A�y�B)
	RULE (OBJECT y) IS A=B � (�y.y�A�y�B)
	RULE (OBJECT y) IS A�B � { y | y�A�y�B }
	RULE (OBJECT y) IS A�B � { y | y�A�y�B }
	RULE (OBJECT y) IS A-B � { y | y�A�y��B }
	RULE (OBJECT y) IS A� � {y | y��A}
	RULE (OBJECT x, OBJECT y) IS ��(C) � { x | �y. x�y�y�C }
	RULE (OBJECT x, OBJECT y) IS ��(C) � { x | �y. y�C�x�y }
	RULE (OBJECT x) IS Pow(A) � { x | x�A }
	RULE (OBJECT x, OBJECT y) IS A�B � { <x,y>  | x�A�y�B }
	RULE (OBJECT x, OBJECT y, OBJECT z) IS A�B � { <x,z> | �y.<x,y>�A�<y,z>�B }
END
