/* $Id$ */

/*
	The multi-conclusion sequent calculus
*/

FONTS "Konstanz"
INITIALISE displaystyle tree

INFIX   1000    1000    �
INFIX   1101    1100    �
INFIX   1500    1500    �
INFIX   1600    1600    �
PREFIX �

LEFTFIX � .
LEFTFIX � .

CLASS FORMULA A, B, C, D, P, Q, R, S
CLASS VARIABLE x, y, z
CLASS CONSTANT F, G, H, m, n

BIND    x SCOPE P IN �x . P
BIND    x SCOPE P IN �x . P

SEQUENT IS BAG � BAG

RULE	axiom(A)		INFER A � A
RULE	"�"		FROM � A AND � B INFER � A�B
RULE	"��"		FROM A, B �  INFER   A�B � 
RULE	"��"		FROM � A,B INFER � A�B
RULE	"��"		FROM A �  AND B �  INFER A�B � 
RULE	"��"		FROM A � INFER � �A
RULE	"��"		FROM � A INFER �A � 
RULE	"��"		FROM A � B INFER � A�B
RULE	"��"		FROM A�B � A AND B �  INFER A�B �
RULE	"��"		FROM � A�B AND � B�A INFER � A�B
RULE	"��"		FROM A�B, B�A �  INFER A�B � 
RULE	"��"(OBJECT m) WHERE FRESH m
			FROM � A[x\m] INFER � �x . A
RULE	"��"(B)		FROM �x.A, A[x\B] � INFER �x.A �
RULE	"��"(B)		FROM � A[x\B] INFER � �x.A
RULE	"��"(OBJECT m) WHERE FRESH m
			FROM  A[x\m] � INFER �x.A �
RULE	cut(A)		FROM � A AND A � INFER �
RULE	"weaken�"(A)	FROM � INFER A � 
RULE	"�weaken"(A)	FROM � INFER � A
RULE	"contract�"(A)	FROM A, A � INFER A � 
RULE	"�contract"(A)	FROM � A, A INFER � A 
                                
MENU Rules IS
	ENTRY axiom	IS  axiom
	SEPARATOR
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	SEPARATOR
	ENTRY "�"	IS "�"
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	ENTRY "��"	IS "��"
	SEPARATOR
	ENTRY cut		IS cut
	ENTRY "weaken�"	IS "weaken�"
	ENTRY "�weaken"	IS "�weaken"
	ENTRY "contract�"	IS "contract�"
	ENTRY "�contract"	IS "�contract"
END

HYPHIT	A � A	IS axiom       
HYPHIT	A�B �	IS "��"        
HYPHIT	A�B �	IS "��"
HYPHIT	A�B � 	IS "��"    
HYPHIT	�A �		IS "��"    
HYPHIT	A�B �	IS "��"    
HYPHIT	�x.A �	IS "��"
HYPHIT	�x.A �	IS "��"

CONCHIT	B�C	IS "�"
CONCHIT	B�C	IS "��"      
CONCHIT	B�C	IS "��"
CONCHIT	�B	IS "��"       
CONCHIT	B�C	IS "��"     
CONCHIT	�x.B	IS "��"  
CONCHIT	�x.B	IS "��"  

AUTOMATCH axiom

STRUCTURERULE CUT            		cut
STRUCTURERULE LEFTWEAKEN     	"weaken�"
STRUCTURERULE RIGHTWEAKEN   	"�weaken"
STRUCTURERULE LEFTCONTRACT   	"contract�"
STRUCTURERULE RIGHTCONTRACT 	"�contract"
