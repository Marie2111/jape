/* $Id$ */

/* LF-style variables in the sequent calculus (multiple and single conclusion) */

PREFIX	10		var
POSTFIX	10		inscope

RULES "inscope" ARE
	�, var x � x inscope
AND	FROM � � A inscope AND � � B inscope INFER � � A�B inscope
AND	FROM � � A inscope AND � � B inscope INFER � � A�B inscope
AND	FROM � � A inscope AND � � B inscope INFER � � A�B inscope
AND	FROM � � A inscope INFER � � �A inscope
AND	FROM �, var x � A inscope INFER � � �x.A inscope
AND	FROM �, var x � A inscope INFER � � �x.A inscope 
END

AUTOMATCH "inscope"

