/* $Id$ */

SEQUENT IS BAG � FORMULA

CLASS VARIABLE x y z c d
CLASS FORMULA A B C D P Q R S
CONSTANT �

SUBSTFIX	2000
JUXTFIX	1900

PREFIX	500		�
INFIX		400L		= �
INFIX		300L		�
INFIX		200L		�
INFIX		100R		� �
INFIX		50L		�

LEFTFIX	10	� .
LEFTFIX	10	� .
LEFTFIX	10	�! .

BIND x SCOPE P IN �x . P
BIND x SCOPE P IN �x . P
BIND x SCOPE P IN �!x . P

INITIALISE autoAdditiveLeft true /* avoid explicit statement of left context */
