/* $Id$ */

/* stuff to add LF vars to the naive set theory encoding */

USE "BnE-Fprime_LF.j" 

RULE "�-I"(OBJECT c) WHERE FRESH c IS FROM new c, c�A � c�B INFER A�B
RULE "=-I"(OBJECT c) IS FROM new c, c�A � c�B AND new c, c�B � c�A INFER A=B
