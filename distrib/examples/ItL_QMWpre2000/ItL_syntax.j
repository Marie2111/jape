/* $Id$ */

INFIX 300L �
INFIX 200L �
INFIX 100R �
PREFIX �

LEFTFIX � .
LEFTFIX � .

PREFIX wellformed, constant

CLASS VARIABLE x, y, z, c, d
CLASS FORMULA A, B, C, P, Q, R, S
/* CLASS CONSTANT c, d */

BIND x SCOPE P IN �x . P
BIND x SCOPE P IN �x . P

INITIALISE autoAdditiveLeft	true /* allow rules to be stated without an explicit left context */
INITIALISE interpretpredicates	true /* allow predicate syntax ... */
