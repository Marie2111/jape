/*	$Id$ */

TACTIC ForwardCutwithSubstSel(Rule) IS
	SEQ	cut 
		(WHEN	(LETSUBSTSEL _A Rule (WITHSUBSTSEL hyp))
				(JAPE (fail(please text-select one or more instances of a sub-formula)))
		)

MENU SetOps IS
	ENTRY "abstraction-I" IS FSSOB ForwardCutwithSubstSel "abstraction-I"
	ENTRY "�-I"
	ENTRY "=-I"
	ENTRY "�-I(L)" IS FOB ForwardCut "�-I(L)"
	ENTRY "�-I(R)" IS FOB ForwardCut "�-I(R)"
	ENTRY "�-I"
	ENTRY "�-I" IS FOB ForwardCut "�-I"
	
	SEPARATOR
	
	ENTRY "abstraction-E" IS FOBSS ForwardCut "abstraction-E"
	ENTRY "�-E" IS FOB ForwardCut2 "�-E"
	ENTRY "=-E(L)" IS FOB ForwardCut "=-E(L)"
	ENTRY "=-E(R)" IS FOB ForwardCut "=-E(R)"
	ENTRY "�-E" IS FOB ForwardUncut "�-E"
	ENTRY "�-E(L)" IS FOB ForwardCut "�-E(L)"
	ENTRY "�-E(R)" IS FOB ForwardCut "�-E(R)"
	ENTRY "�-E" IS FOB ForwardCut "�-E"
	
	SEPARATOR
	
	ENTRY "�-E" IS FOB ForwardCut "�-E"
	ENTRY "A�U"
END

TACTICPANEL "Definitions" IS
	RULE "A��B � �(A�B)" IS INFER A��B � �(A�B)
	RULE "A�{B} � A=B" IS INFER A�{B} � A=B
	RULE "� � {}" IS INFER � � {}
	RULE "A�B � (�y.y�A�y�B)"(OBJECT y) IS INFER A�B � (�y.y�A�y�B)
	RULE "A=B � (�y.y�A�y�B)"(OBJECT y) IS INFER A=B � (�y.y�A�y�B)
	RULE "A�B � { y | y�A�y�B }"(OBJECT y) IS INFER A�B � { y | y�A�y�B }
	RULE "A�B � { y | y�A�y�B }"(OBJECT y) IS INFER A�B � { y | y�A�y�B }
	RULE "A-B � { y | y�A�y��B }"(OBJECT y) IS INFER A-B � { y | y�A�y��B }
	RULE "A� � {y | y��A}"(OBJECT y) IS INFER A� � {y | y��A}
	RULE "��(C) � { x | �y. x�y�y�C }"(OBJECT x, OBJECT y) IS INFER ��(C) � { x | �y. x�y�y�C }
	RULE "��(C) � { x | �y. y�C�x�y }"(OBJECT x, OBJECT y) IS INFER ��(C) � { x | �y. y�C�x�y }
END
