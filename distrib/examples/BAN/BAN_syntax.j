/* $Id$ */

PREFIX #
POSTFIX �

INFIX 300 300 �
INFIX 300 300 �
INFIX 300 300 �

INFIX 201 200 �

INFIX 151 150 �

INFIX 101 100 � /* rassoc: left priority higher */

INFIX 50 50 �

INFIX 10 10 +

OUTFIX {  }
OUTFIX <  >

LEFTFIX � .

CLASS VARIABLE x, k
CLASS FORMULA X, Y, Z
CLASS CONSTANT P, Q, R, K, N
CONSTANT A, B, S

BIND x SCOPE P IN �x . P

SEQUENT IS BAG � FORMULA

INITIALISE autoAdditiveLeft true /* allow rules to be stated without an explicit left context */
