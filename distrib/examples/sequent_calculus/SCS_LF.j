/* $Id$ */

/* single-conclusion sequent calculus with LF-like treatment of variables */

USE "SCS.jt"
USE "sequent_scoping.j"

RULE	"��"(OBJECT m) WHERE FRESH m
			FROM � , constant m � P(m) 				INFER � � �x.P(x)
RULE	"��"(B)	FROM �, P(B) � C AND � � B inscope			INFER �, �x.P(x) � C
RULE	"��"(B)	FROM � � P(B) AND � � B inscope			INFER � � �x.P(x)
RULE	"��"(OBJECT m) WHERE FRESH m
			FROM  �, constant m, P(m) � C 				INFER �, �x.P(x) � C

TACTIC "�� with side condition hidden" IS LAYOUT "��" (0) (WITHSELECTIONS "��")
TACTIC "�� with side condition hidden" IS LAYOUT "��" (0) (WITHSELECTIONS "��")

MENU Rules IS
	ENTRY "��" IS "�� with side condition hidden"
	ENTRY "��" IS "�� with side condition hidden"
END

HYPHIT	�x.A � B	IS "�� with side condition hidden"
CONCHIT	�x.B		IS "�� with side condition hidden"
