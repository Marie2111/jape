/* $Id$ */

/*
	The multi-conclusion sequent calculus, with multiplicative versions of the branching rules (gasp!).
	This encoding is a testbed, so I have made it use the extreme form of axiom, it doesn't copy 
	Dyckhoff-style in the �� and �� rules.  Because of multiplicativity (and sometimes because of
	un-Dyckhoffry), you have to use contraction sometimes.
	RB 14/viii/97
	
	Now an add-on to MCS.jt
*/

/* the differences */
RULE	axiom(A)									INFER A � A
RULE	"�"		FROM �1 � A,�1 AND �2 � B,�2 		INFER �1,�2 � A�B,�1,�2
RULE	"��"		FROM �1,A � �1 AND �2,B � �2		INFER �1,�2,A�B � �1,�2
RULE	"��"		FROM �1 � A,�1 AND �2,B � �2		INFER �1,�2,A�B � �1,�2
RULE	"��"		FROM �1 � A�B,�1 AND �2 � B�A,�2	INFER �1,�2 � A�B,�1,�2
RULE	cut(A)	FROM �1 � A,�1 AND �2,A � �2		INFER �1,�2 � �1,�2

STRUCTURERULE CUT            		cut /* cos it's different now */
