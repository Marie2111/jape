/* $Id$ */

/*
	An all-introduction variant of intuitionistic predicate calculus
	Bernard Sufrin & Richard Bornat, Oxford 1991
	updated Richard Bornat, Hornsey April 1994 (how time flies!)
	updated again July 1996, with proper sequent syntax
*/

USE "sequent_syntax.j"
CONSTANT �

SEQUENT IS BAG � FORMULA

RULE	hyp(A)							INFER �,A � A
RULE	"�"		FROM � � A AND  � � B		INFER � � A�B
RULE	"��"		FROM �, A, B � C			INFER �, A�B � C
RULE	"��(L)"	FROM  � � A 				INFER � � A�B
RULE	"��(R)"	FROM  � � B 				INFER � � A�B
RULE	"��"		FROM �, A � C AND �, B � C	INFER �, A�B � C
RULE	"��"		FROM � � A� � 			INFER � � �A
RULE	"��"		FROM �, A� � � B 			INFER �, �A � B
RULE	"��"		FROM �, A � B 				INFER � � A�B
RULE	"��"		FROM � � A AND �, B � C		INFER �, A�B � C
RULE	"��"		FROM � � A�B AND � � B�A	INFER � � A�B
RULE	"��"		FROM �, A�B,  B�A � C		INFER �, A�B � C
RULE	"��"							INFER �, � � A
RULE	"��"(OBJECT m) WHERE FRESH m
			FROM � � P(m) 				INFER � � �x.P(x)
RULE	"��"(B)	FROM �, P(B) � C 			INFER �, �x.P(x) � C
RULE	"��"(B)	FROM � � P(B)				INFER � � �x.P(x)
RULE	"��"(OBJECT m) WHERE FRESH m
			FROM  �, P(m) � C 			INFER �, �x.P(x) � C
RULE	cut(A)	FROM � � A AND �, A � C 		INFER � � C
RULE	thin(A)	FROM � � B 				INFER �, A � B
RULE	dup(A)	FROM �, A, A � B 			INFER �, A � B

MENU Tracing IS
     CHECKBOX tactictracing "Trace" 
END

MENU Rules IS
	ENTRY hyp
	ENTRY cut
	SEPARATOR
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	SEPARATOR
	ENTRY "�"
	ENTRY "��(L)"
	ENTRY "��(R)"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
END

TACTIC  "��"	IS 
	(ALT	(PROVE  "��(L)"  ( hyp))
	                     (PROVE  "��(R)"  ( hyp))
		(SEQ (EXPLAIN ("��" does not lead to an immediate conclusion)) (FAIL)))
MENU Auto
	TACTIC "Prove this propositional goal"		IS (PROVE Propositional)
	TACTIC "Prove remaining propositional goals"	IS Propositional
	TACTIC Propositional IS
		DO	(ALT	(PROVE hyp)
		      		"��"
		      		"��" "��" "�" "��" "��" 
		      		"��"
		      		"��"
		      		(SEQ "��(L)" (PROVE Propositional) "��(R)" (PROVE Propositional))
		      		"��(L)"
		      		"��(R)"
		      		"��"
			)
END
	
HYPHIT	A � A	IS hyp       
HYPHIT	A�B � C	IS "��"    
HYPHIT	A�B � C	IS "��"    
HYPHIT	A�B � C	IS "��"    
HYPHIT	�A � B	IS "��"     
HYPHIT	A�B � C	IS "��"   
HYPHIT	� � A	IS "��" 
HYPHIT	�x.A � B	IS "��"
HYPHIT	�x.A � B	IS "��"

CONCHIT	B�C	IS "�"
CONCHIT	B�C	IS "��"      
CONCHIT	B�C	IS "��"      
CONCHIT	�B	IS "��"       
CONCHIT	B�C	IS "��"     
CONCHIT	�x.B	IS "��"  
CONCHIT	�x.B	IS "��"  

/*AUTOMATCH hyp*/

STRUCTURERULE IDENTITY    hyp
STRUCTURERULE CUT            cut
STRUCTURERULE WEAKEN     thin
