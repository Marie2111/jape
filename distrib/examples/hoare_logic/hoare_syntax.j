﻿/* $Id$ */ 

CLASS VARIABLE x y z a b c d v i j k m n q r
CLASS FORMULA A B C D E F G I J M N  P Q R S T U V 
CLASS CONSTANT K
CLASS BAG FORMULA Γ

CONSTANT true false
CONSTANT ⊥ /* to satisfy I2L syntax */

PREFIX	10	actual

INFIX 10 L ;
INFIX 12 L :=

INFIX 50 L ⊕
INFIX 60 L ↦

INFIX	100R	→
INFIX	120L	∨
INFIX	140L	∧

LEFTFIX	180	∀ .
LEFTFIX	180	∃ .

INFIX	300L	<   >   ≤   ≥   ≠   =   ≡   ¬≡   

INFIX 	400 L	+ -
INFIX 	410 L	* div

PREFIX	1200	¬

JUXTFIX	9000
SUBSTFIX	10000 	« E / x  » /* so that { }, [ ] are available for other uses */

BIND x SCOPE P IN ∀x . P
BIND x SCOPE P IN ∃x . P

SEQUENT IS BAG ⊢ FORMULA

INITIALISE autoAdditiveLeft true /* allow rules to be stated without an explicit left context */
INITIALISE interpretpredicates true /* allow predicate syntax ... */

OUTFIX { } /* for assertions */
OUTFIX [ ] /* for indexing */

OUTFIX if then else fi
OUTFIX while do od

CONSTANT skip tilt

INITIALISE hidetransitivity true
INITIALISE hidereflexivity true