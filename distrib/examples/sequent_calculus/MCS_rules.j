/* $Id$ */

/*
	The multi-conclusion sequent calculus
*/

FONTS "Konstanz 12 9 Detroit"
DISPLAY TREE

INFIX   1000    1000    �
INFIX   1100    1100    �
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
RULE	"�-R"		FROM � A AND � B INFER � A�B
RULE	"�-L"		FROM A, B �  INFER   A�B � 
RULE	"�-R"		FROM � A,B INFER � A�B
RULE	"�-L"		FROM A �  AND B �  INFER A�B � 
RULE	"�-R"		FROM A � INFER � �A
RULE	"�-L"		FROM � A INFER �A � 
RULE	"�-R"		FROM A � B INFER � A�B
RULE	"�-L"		FROM A�B � A AND B �  INFER A�B �
RULE	"�-R"		FROM � A�B AND � B�A INFER � A�B
RULE	"�-L"		FROM A�B, B�A �  INFER A�B � 
RULE	"�-R"(OBJECT y) WHERE FRESH y
			FROM � A[x\y] INFER � �x . A
RULE	"�-L"(B)		FROM �x.A, A[x\B] � INFER �x.A �
RULE	"�-R"(B)		FROM � A[x\B] INFER � �x.A
RULE	"�-L"(OBJECT y) WHERE FRESH y
			FROM  A[x\y] � INFER �x.A �
RULE	cut(A)		FROM � A AND A � INFER �
RULE	leftweaken(A)	FROM � INFER A � 
RULE	rightweaken(A)	FROM � INFER � A
RULE	leftcontract(A)	FROM A, A � INFER A � 
RULE	rightcontract(A)	FROM � A, A INFER � A 
                                
 
THEOREM	modusponens	IS A, A�B � B
THEOREM contradiction	IS A, �A �

MENU Rules IS
	ENTRY axiom	IS  axiom
	SEPARATOR
	ENTRY "�-L"	IS "�-L"
	ENTRY "�-L"	IS "�-L"
	ENTRY "�-L"	IS "�-L"
	ENTRY "�-L"	IS "�-L"
	ENTRY "�-L"	IS "�-L"
	ENTRY "�-L"	IS "�-L"
	ENTRY "�-L"	IS "�-L"
	SEPARATOR
	ENTRY "�-R"	IS "�-R"
	ENTRY "�-R"	IS "�-R"
	ENTRY "�-R"	IS "�-R"
	ENTRY "�-R"	IS "�-R"
	ENTRY "�-R"	IS "�-R"
	ENTRY "�-R"	IS "�-R"
	ENTRY "�-R"	IS "�-R"
	SEPARATOR
	ENTRY cut		IS cut
	ENTRY leftweaken	IS leftweaken
	ENTRY rightweaken	IS rightweaken
	ENTRY leftcontract	IS leftcontract
	ENTRY rightcontract	IS rightcontract
END

HYPHIT	A � A	IS axiom       
HYPHIT	A�B �	IS "�-L"        
HYPHIT	A�B �	IS "�-L"
HYPHIT	A�B � 	IS "�-L"    
HYPHIT	�A �	IS "�-L"    
HYPHIT	A�B �	IS "�-L"    
HYPHIT	�x.A �	IS "�-L"
HYPHIT	�x.A �	IS "�-L"

CONCHIT	B�C	IS "�-R"
CONCHIT	B�C	IS "�-R"      
CONCHIT	B�C	IS "�-R"
CONCHIT	�B	IS "�-R"       
CONCHIT	B�C	IS "�-R"     
CONCHIT	�x.B	IS "�-R"  
CONCHIT	�x.B	IS "�-R"  

AUTOMATCH axiom

STRUCTURERULE IDENTITY    axiom
STRUCTURERULE CUT            cut
STRUCTURERULE LEFTWEAKEN     leftweaken
STRUCTURERULE RIGHTWEAKEN   rightweaken
STRUCTURERULE LEFTCONTRACT   leftcontract
STRUCTURERULE RIGHTCONTRACT rightcontract
