/* $Id$ */

INFIX 300 300 �
INFIX 200 200 �
INFIX 101 100 �	/* � is right-associative, which means a higher _leftwards_ precedence!! */
PREFIX �

LEFTFIX � .
LEFTFIX � .

CLASS VARIABLE x, y, z
CLASS FORMULA A, B, C, P, Q, R, S
CLASS CONSTANT c

BIND x SCOPE P IN �x . P
BIND x SCOPE P IN �x . P

INITIALISE autoAdditiveLeft	true /* allow rules to be stated without an explicit left context */
INITIALISE interpretpredicates	true /* allow predicate syntax ... */
