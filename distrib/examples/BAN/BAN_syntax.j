/* $Id$ */

PREFIX #
POSTFIX �

INFIX 300L �,  �, �
INFIX 200R �
INFIX 150R �
INFIX 100R �
INFIX 50L �
INFIX 10L +

OUTFIX {  }
OUTFIX <  >

LEFTFIX � .

CLASS VARIABLE x, k
CLASS FORMULA X, Y, Z
CLASS CONSTANT P, Q, R, K, N, T
CONSTANT A, B, S

BIND x SCOPE P IN �x . P

SEQUENT IS BAG � FORMULA

INITIALISE autoAdditiveLeft true /* allow rules to be stated without an explicit left context */
