/* $Id$ */

/* stuff to use LF-style vars in the BnE logic */

PREFIX	10		var
POSTFIX	10		inscope

RULE "�-E"(B)						IS FROM �x. A(x) AND B inscope INFER A(B)
RULE "�-E"(OBJECT c) WHERE FRESH c AND c NOTIN �x.A
								IS FROM �x.A(x) AND var c, A(c) � C INFER C

RULE "�-I"(OBJECT c) WHERE FRESH c	IS FROM var c � A(c) INFER �x .A(x)
RULE "�-I"(B)						IS FROM A(B) AND B inscope INFER �x.A(x)
RULE "�!-I"(OBJECT c, OBJECT d) WHERE FRESH c,d AND c,d NOTIN �!x.A(x)
								IS FROM �x.A(x) AND var c,var d,A(c),A(d) � c=d INFER �!x.A(x)

RULES "inscope" ARE
							INFER var x � x inscope
AND	FROM A inscope AND B inscope	INFER A�B inscope
AND	FROM A inscope AND B inscope	INFER A�B inscope
AND	FROM A inscope AND B inscope	INFER A�B inscope
AND	FROM A inscope				INFER �A inscope
AND	FROM var x � A inscope		INFER �x.A inscope
AND	FROM var x � A inscope		INFER �x.A inscope
AND	FROM var x � A inscope		INFER �!x.A inscope
END

AUTOMATCH "inscope"

TACTIC "�-E with side condition hidden" IS LAYOUT "�-E" (0) (WITHARGSEL "�-E")
TACTIC "�-I with side condition hidden" IS LAYOUT "�-I" (0) (WITHARGSEL "�-I")
	
TACTIC "�-E tac" IS FOBSS ForwardCut "�-E with side condition hidden"
TACTIC "�-I tac" IS "�-I with side condition hidden"

