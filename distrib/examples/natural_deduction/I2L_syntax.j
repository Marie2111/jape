/* $Id$ */

CLASS VARIABLE x y z   i j k
CLASS FORMULA A B C   E F G  P  R S T
CLASS BAG FORMULA �

CONSTANT �

PREFIX	10		actual
/* POSTFIX	10		inscope   no longer used. I don't think that proof files will crash without it */

INFIX		100R		�
INFIX		120L		�
INFIX		140L		�

LEFTFIX	180		� .
LEFTFIX	180		� .

PREFIX	200		�

JUXTFIX		300
SUBSTFIX	400 

BIND x SCOPE A IN �x . A
BIND x SCOPE B IN �x . B

SEQUENT IS BAG � FORMULA

INITIALISE autoAdditiveLeft		true /* allow rules to be stated without an explicit left context */
INITIALISE interpretpredicates	true /* allow predicate syntax ... */
