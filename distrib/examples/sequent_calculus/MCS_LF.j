/* $Id$ */

USE "sequent_scoping.j"

RULE	"��"(OBJECT m) WHERE FRESH m
			FROM �, var m � A(m),�				INFER � � �x.A(x),�
RULE	"��"(B)	FROM �, A(B) � � AND � � B inscope		INFER �,�x.A(x) � �
RULE	"��"(B)	FROM � � A(B),� AND � � B inscope		INFER � � �x.A(x),�
RULE	"��"(OBJECT m) WHERE FRESH m
			FROM  �, var m, A(m) � �				INFER �, �x.A(x) � �

TACTIC "�� with side condition hidden" IS LAYOUT "��" (0) (WITHSELECTIONS "��")
TACTIC "�� with side condition hidden" IS LAYOUT "��" (0) (WITHSELECTIONS "��")

MENU Rules IS
	ENTRY "��" IS "�� with side condition hidden"
	ENTRY "��" IS "�� with side condition hidden"
END

HYPHIT	�x.A �	IS "�� with side condition hidden"
CONCHIT	� �x.B	IS "�� with side condition hidden"
