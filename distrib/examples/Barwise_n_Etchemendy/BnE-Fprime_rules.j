/* $Id$ */

RULE cut(B) IS FROM B AND B � C INFER C
RULE thin(A) IS FROM C INFER A � C
RULE dup(A) IS FROM A,A � C INFER A � C

RULE "�-E"(A) IS FROM A AND A�B INFER B
TACTIC "�-E forward"(Z) IS
	WHEN	(LETHYP (_A�_B) (ForwardCut2 "�-E"))
	          	(LETHYP _A (ForwardCut "�-E"))
	           	(JAPE(fail(what's this in "�-E" forward?)))

TACTIC "�-E forward"(rule) IS
	WHEN	(LETHYP (_A�_B) (ForwardCut2 rule))
	          	(LETHYP _A (ForwardCut rule))
	           	(JAPE(fail(what's this in rule forward?)))

RULE "�-E(L)"(B) IS FROM B AND A�B INFER A
TACTIC "�-E(L) forward"(Z) IS "�-E forward" "�-E(L)"

RULE "�-E(R)"(A) IS FROM A AND A�B INFER B
TACTIC "�-E(R) forward"(Z) IS "�-E forward" "�-E(R)"

RULE "�-E(L)"(B) IS FROM A � B INFER A

RULE "�-E(R)"(A) IS FROM A � B INFER B

RULE "�-E"(A,B) IS FROM A � B AND A � C AND B � C INFER C

RULE "�-E" IS FROM ��A INFER A

RULE "�-E" IS FROM � INFER A

RULE "�-E"(B) IS FROM �x.A(x) INFER A(B)

RULE "�-E"(OBJECT c) WHERE FRESH c AND c NOTIN �x.A(x) IS FROM �x.A(x) AND A(c) � C INFER C

RULE "�!-E(1)" IS FROM �!x.A(x) INFER �x.A(x)
RULE "�!-E(2)"(OBJECT y) IS FROM �!x.A(x) INFER �x.�y.A(x)�A(y)�x=y

TACTIC ForwardCut(Rule) IS SEQ cut (WITHARGSEL Rule) (WITHHYPSEL hyp)

TACTIC ForwardCut2(Rule) IS SEQ cut (WITHARGSEL Rule) (JAPE(SUBGOAL 1)) (WITHHYPSEL hyp)

TACTIC ForwardUncut(Rule) IS SEQ (WITHARGSEL Rule) (WITHHYPSEL hyp)

TACTIC FOB (Forward, Rule) IS 
	WHEN 
		(LETHYP _P
			(ALT	(Forward Rule)
				(WHEN	(LETARGSEL _Q 
							(JAPE(failgivingreason(Rule is not applicable to assumption ' _P ' 
															with argument ' _Q ')))
						)
						(JAPE(failgivingreason(Rule is not applicable to assumption ' _P ')))
				)
			)
		) 
		(ALT	(WITHSELECTIONS Rule)
			(WHEN	(LETARGSEL _P (JAPE(failgivingreason(Rule is not applicable with argument ' _P '))))
					(JAPE(failgivingreason(Rule is not applicable)))
			)
		)
   
/* we really need a case statement.  This is just a version of FOB, and there are many others ... */
TACTIC FOBSS (Forward, Rule) IS 
	WHEN 
		(LETHYP _P
			(ALT	(Forward Rule)
				(WHEN	(LETARGSEL _Q 
							(JAPE(failgivingreason(Rule is not applicable to assumption ' _P ' 
															with argument ' _Q ')))
						)
						(JAPE(failgivingreason(Rule is not applicable to assumption ' _P ')))
				)
			)
		) 
		(LETCONCSUBSTSEL _P 
			(ALT	(WITHSUBSTSEL (WITHHYPSELRule))
				(LETGOAL _Q
					(JAPE(failgivingreason(Rule is not applicable to conclusion ' _Q ' with substitution ' _P ')))
				)
			)
		)
		(ALT	(WITHSELECTIONS Rule)
			(JAPE(failgivingreason(Rule is not applicable to that conclusion)))
		)
   
TACTIC FSSOB (Forward, Rule) IS 
	WHEN
		(LETHYPSUBSTSEL _P (Forward Rule)) 
		(ALT	(WITHSELECTIONS Rule)
			(WHEN	(LETARGSEL _P (JAPE(failgivingreason(Rule is not applicable with argument ' _P '))))
					(JAPE(failgivingreason(Rule is not applicable)))
			)
		)
   
RULE "�-I"  IS FROM A � B INFER A�B
RULE "�-I"  IS FROM A � B  AND B � A INFER A�B
RULE "�-I"  IS FROM A AND B INFER A � B
RULE "�-I(L)"   IS FROM A INFER A � B
RULE "�-I(R)"   IS FROM B INFER A � B
RULE "�-I"(B)   IS FROM A � � INFER �A
RULE "�-I"	IS FROM P AND �P INFER �
RULE "�-I"(OBJECT c) WHERE FRESH c IS FROM A(c) INFER �x .A(x)
RULE "�-I"(B)   IS FROM A(B) INFER �x.A(x)
RULE "�!-I"(OBJECT c,OBJECT d) WHERE FRESH c,d AND c,d NOTIN �!x.A(x) IS 
	FROM �x.A(x) AND A(c),A(d) � c=d INFER �!x.A(x)

RULE "A=A" IS INFER A=A
RULE hyp(A) IS INFER A � A

AUTOMATCH hyp

STRUCTURERULE IDENTITY    hyp
STRUCTURERULE CUT            cut
STRUCTURERULE WEAKEN     thin

RULE "rewrite � �" (A) IS FROM A � B AND P(B) INFER P(A)
RULE "rewrite � �" (B) IS FROM A � B AND P(A) INFER P(B)
RULE "rewrite = �" (A) IS FROM A=B AND P(B) INFER P(A)
RULE "rewrite = �" (B) IS FROM A=B AND P(A) INFER P(B)
RULE "rewrite � �" (A) IS FROM A�B AND P(B) INFER P(A)
RULE "rewrite � �" (B) IS FROM A�B AND P(A) INFER P(B)
