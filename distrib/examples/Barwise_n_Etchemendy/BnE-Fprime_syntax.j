/* $Id$ */

SEQUENT IS BAG � FORMULA

INFIX 400L =, �
INFIX 300L �
INFIX 200L �
INFIX 100R �, �
INFIX 50L �

PREFIX �

LEFTFIX � .
LEFTFIX � .
LEFTFIX �! .

CLASS VARIABLE x, y, z
CLASS FORMULA A, B, C, D, P, Q, R, S
CLASS CONSTANT c, d
CONSTANT �

BIND x SCOPE P IN �x . P
BIND x SCOPE P IN �x . P
BIND x SCOPE P IN �!x . P

INITIALISE autoAdditiveLeft true /* avoid explicit statement of left context */
