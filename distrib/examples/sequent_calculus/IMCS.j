/* $Id$ */

/*
	The _intuitionistic_ multiple-conclusion sequent calculus!!
*/

USE "MCS.jt" /* the default */

/* the differences */
RULE	"��"		FROM �,A � 					INFER � � �A,�
RULE	"��"		FROM � � A					INFER �,�A � �
RULE	"��"		FROM �,A � B	 				INFER � � A�B,�
RULE	"��"		FROM � � A AND �,B � �			INFER �,A�B � �
