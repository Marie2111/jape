/* $Id$ */

/*
	The multi-conclusion sequent calculus, with multiplicative versions of the branching rules (gasp!).
	This encoding is a testbed, so I have made it use the extreme form of axiom, it doesn't copy 
	Dyckhoff-style in the �� and �� rules.  Because of multiplicativity and un-Dyckhoffry, you have
	to use contraction sometimes.
	RB 20/ix/96
*/

USE "MCS.jt" /* the default */

/* the differences */
RULE	axiom(A)								INFER A � A
RULE	"�"		FROM � � A,� AND �' � B,�' 		INFER �,�' � A�B,�,�'
RULE	"��"		FROM �,A � � AND �',B � �'		INFER �,�',A�B � �,�'
RULE	"��"		FROM � � A,� AND �',B � �'		INFER �,�',A�B � �,�'
RULE	"��"		FROM � � A�B,� AND �' � B�A,�'	INFER �,�' � A�B,�,�'
RULE	cut(A)	FROM � � A,� AND �',A � �'		INFER �,�' � �,�'

STRUCTURERULE CUT            		cut /* cos it's different now */
