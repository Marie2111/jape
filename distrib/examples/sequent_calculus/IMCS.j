/* $Id$ */

/*
	The _intuitionistic_ multiple-conclusion sequent calculus!! (add after MCS.jt)
*/

/* the differences */
RULE	"��"		FROM �,A � 					INFER � � �A,�
RULE	"��"		FROM � � A					INFER �,�A � �
RULE	"��"		FROM �,A � B	 				INFER � � A�B,�
RULE	"��"		FROM � � A AND �,B � �			INFER �,A�B � �
