/* $Id$ */

/* syntax of very simple set theory, for QMW IDS course 1996 */

CLASS VARIABLE u v w
CONSTANT � � U

PREFIX	800		�� ��
POSTFIX	800		�
INFIX		700L		� � -
INFIX		600L		�
INFIX		500L		� ��
/* 400 is = in BnE-Fprime_syntax.j */

OUTFIX { | }

BIND y SCOPE P IN { y | P }
