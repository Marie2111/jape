/* $Id$ */

/* syntax of very simple set theory, for QMW IDS course 1996 */

CLASS VARIABLE u, v, w
CONSTANT �, �, U

INFIX 700 700 �, �, -
INFIX 600 600 �
INFIX 500 500 �, ��
/* 400 is = in BnE-Fprime_syntax.j */

OUTFIX { | }
PREFIX ��, ��
POSTFIX �

BIND y SCOPE P IN { y | P }
