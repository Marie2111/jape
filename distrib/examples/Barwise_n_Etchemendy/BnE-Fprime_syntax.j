/* $Id$ */

SEQUENT IS BAG � FORMULA

INFIX 400 400 =, �
INFIX 300 300 �
INFIX 200 200 �
INFIX 101 100 �, �
INFIX 50 50 �

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
