/* $Id$ */

/*
	The multi-conclusion sequent calculus. Dyckhoffery removed.
*/

USE "sequent_syntax.j"

SEQUENT IS BAG � BAG

RULE	axiom(A)								INFER �,A � A,�
RULE	"�"		FROM � � A,� AND � � B,� 		INFER � � A�B,�
RULE	"��"		FROM �,A, B � � 				INFER �,A�B � �
RULE	"��"		FROM � � A,B,� 				INFER � � A�B,�
RULE	"��"		FROM �,A � � AND �,B � �		INFER �,A�B � �
RULE	"��"		FROM �,A � �					INFER � � �A,�
RULE	"��"		FROM � � A,� 					INFER �,�A � �
RULE	"��"		FROM �,A � B,� 				INFER � � A�B,�
RULE	"��"		FROM � � A,� AND �,B � �		INFER �,A�B � �
RULE	"��"		FROM � � A�B,� AND � � B�A,�	INFER � � A�B,�
RULE	"��"		FROM �, A�B, B�A � �			INFER �,A�B � �
RULE	"��"(OBJECT m) WHERE FRESH m
			FROM � � A(m),�				INFER � � �x.A(x),�
RULE	"��"(B)	FROM �, A(B) � �				INFER �,�x.A(x) � �
RULE	"��"(B)	FROM � � A(B),�				INFER � � �x.A(x),�
RULE	"��"(OBJECT m) WHERE FRESH m
			FROM  �,A(m) � �				INFER �, �x.A(x) � �
RULE	cut(A)	FROM � � A,� AND �,A � �		INFER � � �
RULE	"weaken�"(A)	FROM � � �				INFER �,A � �
RULE	"�weaken"(A)	FROM � � �				INFER � � A,�
RULE	"contract�"(A)	FROM �, A, A � �			INFER �, A � �
RULE	"�contract"(A)	FROM � � A,A,�			INFER � � A,�
                                
MENU Rules IS
	ENTRY axiom
	SEPARATOR
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	SEPARATOR
	ENTRY "�"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	ENTRY "��"
	SEPARATOR
	ENTRY cut	
	ENTRY "weaken�"
	ENTRY "�weaken"
	ENTRY "contract�"
	ENTRY "�contract"
END

HYPHIT	A � A	IS axiom       
HYPHIT	A�B �	IS "��"        
HYPHIT	A�B �	IS "��"
HYPHIT	A�B � 	IS "��"    
HYPHIT	�A �		IS "��"    
HYPHIT	A�B �	IS "��"    
HYPHIT	�x.A �	IS "��"
HYPHIT	�x.A �	IS "��"

CONCHIT	� B�C	IS "�"
CONCHIT	� B�C	IS "��"      
CONCHIT	� B�C	IS "��"
CONCHIT	� �B		IS "��"       
CONCHIT	� B�C	IS "��"     
CONCHIT	� �x.B	IS "��"  
CONCHIT	� �x.B	IS "��"  

AUTOMATCH axiom

STRUCTURERULE CUT            		cut
STRUCTURERULE LEFTWEAKEN     	"weaken�"
STRUCTURERULE RIGHTWEAKEN   	"�weaken"
