/* $Id$ */

/* syntax of very simple set theory, for QMW IDS course 1997 */

CLASS VARIABLE u v w
CONSTANT � � U

OUTFIX < >
PREFIX	800		�� ��
POSTFIX	800		�
INFIX		700L		� � -
INFIX		600L		�
INFIX		500L		� ��
/* 400 is = in BnE-Fprime_syntax.j */

OUTFIX { | }

BIND y SCOPE P IN { y | P }
BIND x y SCOPE P IN { <x,y> | P }
