/* $Id$ */

/* stuff to use LF-style vars in the BnE logic */

PREFIX	10		new
POSTFIX	10		inscope

RULES "�-E"(B) ARE 
	FROM � x .A(x) AND B inscope INFER A(B)
AND	FROM � x,y .A(x,y) AND B inscope AND C inscope INFER A(B,C)
AND	FROM � x,y,z .A(x,y,z) AND B inscope AND C inscope AND D inscope INFER A(B,C,D)
AND	FROM � w,x,y,z .A(w,x,y,z) AND B inscope AND C inscope AND D inscope AND E inscope INFER A(B,C,D,E)
END
RULES "�-E" ARE
	(OBJECT c) WHERE FRESH c AND c NOTIN � x .A(x) FROM � x .A(x) AND new c, A(c) � C INFER C
AND	(OBJECT c,OBJECT d) WHERE FRESH c,d AND c,d NOTIN � x,y .A(x,y) 
		FROM � x,y .A(x,y) AND new c, new d, A(c,d) � C INFER C
AND	(OBJECT c,OBJECT d,OBJECT e) WHERE FRESH c,d,e AND c,d,e NOTIN � x,y,z .A(x,y,z) 
		FROM � x,y,z .A(x,y,z) AND new c, new d, new e, A(c,d,e) � C INFER C
AND	(OBJECT c,OBJECT d,OBJECT e,OBJECT f) WHERE FRESH c,d,e,f AND c,d,e,f NOTIN � w,x,y,z .A(w,x,y,z) 
		FROM � w,x,y,z .A(w,x,y,z) AND new c, new d, new e, new f, A(c,d,e,f) � C INFER C
END

RULES "�-I" ARE
	(OBJECT c) WHERE FRESH c FROM new c � A(c) INFER � x .A(x)
AND	(OBJECT c, OBJECT d) WHERE FRESH c,d FROM new c, new d � A(c,d) INFER � x,y .A(x,y)
AND	(OBJECT c, OBJECT d, OBJECT e) WHERE FRESH c,d,e 
		FROM new c, new d, new e � A(c,d,e) INFER � x,y,z .A(x,y,z)
AND	(OBJECT c, OBJECT d, OBJECT e, OBJECT f) WHERE FRESH c,d,e,f 
		FROM new c, new d, new e, new f � A(c,d,e,f) INFER � w,x,y,z .A(w,x,y,z)
END
RULES "�-I"(B) ARE 
	FROM A(B) AND B inscope INFER � x.A(x)
AND	FROM A(B,C) AND B inscope AND C inscope INFER � x,y . A(x,y)
AND	FROM A(B,C,D) AND B inscope AND C inscope AND D inscope INFER � x,y,z . A(x,y,z)
AND	FROM A(B,C,D,E) AND B inscope AND C inscope AND D inscope AND E inscope INFER � w,x,y,z . A(w,x,y,z)
END
RULES "�!-I" ARE
	(OBJECT c1,OBJECT c2) WHERE FRESH c1,c2 AND c1,c2 NOTIN �! x .A(x) 
		FROM � x .A(x) AND new c1, new c2, A(c1),A(c2) � c1=c2 INFER �! x .A(x)
AND	(OBJECT c1,OBJECT c2, OBJECT d1, OBJECT d2) WHERE FRESH c1,c2,d1,d2 AND c1,c2,d1,d2 NOTIN �! x,y .A(x,y) 
		FROM � x,y .A(x,y) AND new c1, new c2, new d1, new d2, A(c1,d1),A(c2,d2) � c1=c2�d1=d2 
		INFER �! x,y .A(x,y)
AND	(OBJECT c1,OBJECT c2, OBJECT d1, OBJECT d2, OBJECT e1,OBJECT e2) 
	WHERE FRESH c1,c2,d1,d2,e1,e2 AND c1,c2,d1,d2,e1,e2 NOTIN �! x,y,z .A(x,y,z) 
		FROM � x,y,z .A(x,y,z) 
		AND new c1, new c2, new d1, new d2, new e1, new e2, A(c1,d1,e1),A(c2,d2,e2) � c1=c2�d1=d2�e1=e2 
		INFER �! x,y,z .A(x,y,z)
AND	(OBJECT c1,OBJECT c2, OBJECT d1, OBJECT d2, OBJECT e1,OBJECT e2, OBJECT f1,OBJECT f2) 
	WHERE FRESH c1,c2,d1,d2,e1,e2,f1,f2 AND c1,c2,d1,d2,e1,e2,f1,f2 NOTIN �! w,x,y,z .A(w,x,y,z) 
		FROM � w,x,y,z .A(w,x,y,z) 
		AND new c1, new c2, new d1, new d2, new e1, new e2, new f1, new f2, 
			A(c1,d1,e1,f1),A(c2,d2,e2,f2) � c1=c2�d1=d2�e1=e2�f1=f2 
		INFER �! w,x,y,z .A(w,x,y,z)
END

RULES "inscope" ARE
							INFER new x � x inscope
AND	FROM A inscope AND B inscope	INFER A�B inscope
AND	FROM A inscope AND B inscope	INFER A�B inscope
AND	FROM A inscope AND B inscope	INFER A�B inscope
AND	FROM A inscope				INFER �A inscope
AND	FROM new x � A inscope		INFER �x.A inscope
AND	FROM new x � A inscope		INFER �x.A inscope
AND	FROM new x � A inscope		INFER �!x.A inscope
END

AUTOMATCH "inscope"

TACTIC "�-E with side condition hidden" IS LAYOUT "�-E" (0) (WITHARGSEL "�-E")
TACTIC "�-I with side condition hidden" IS LAYOUT "�-I" (0) (WITHARGSEL "�-I")
	
TACTIC "�-E tac" IS FOBSS ForwardCut 0 "�-E with side condition hidden"
TACTIC "�-I tac" IS "�-I with side condition hidden"

