/* $Id$ */

/* these rules are stated without an explicit left-context �. This makes them more friendly
 * to the innocent natural-deductionist (:-)), or so we hope. The initialisation of autoAdditiveLeft
 * in I2L_syntax.j is what does the magic.
 */
 
TACTIC Fail (x) IS SEQ (ALERT x) STOP

RULE cut(B) IS FROM B AND B � C INFER C
RULE thin(A) IS FROM C INFER A � C

RULE "� elim"				IS FROM A�B AND A INFER B
RULE "� elim(L)"			IS FROM A � B INFER A
RULE "� elim(R)"			IS FROM A � B INFER B
RULE "� elim"				IS FROM A � B AND A � C AND B � C INFER C
RULE "� elim (classical)"	IS FROM �A � � INFER A
RULE "� elim (constructive)"	
								IS FROM � INFER B
RULE "� elim"(c)			IS FROM �x. A(x) AND c inscope INFER A(c)
RULE "� elim"(OBJECT c) WHERE FRESH c AND c NOTIN �x.A(x)
								IS FROM �x.A(x) AND actual c, A(c) � C INFER C

RULE "� intro"					IS FROM A � B INFER A�B
RULE "� intro"					IS FROM A AND B INFER A � B
RULE "� intro(L)"(B)		IS FROM A INFER A � B
RULE "� intro(R)"(B)		IS FROM A INFER B � A
RULE "� intro"					IS FROM A � � INFER �A
RULE "� intro"(B)			IS FROM B AND �B INFER �
RULE "� intro"(OBJECT c) WHERE FRESH c
								IS FROM actual c � A(c) INFER �x .A(x)
RULE "� intro"(c)				IS FROM A(c) AND c inscope INFER �x.A(x)

RULE hyp(A) IS INFER A � A
AUTOMATCH hyp

IDENTITY	hyp
CUT			cut
WEAKEN	thin

RULE "inscope"(x) IS INFER actual x � x inscope
AUTOMATCH "inscope"

