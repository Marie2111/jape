/* $Id$ */

/* ways of stopping � proving �, without an effort */

RULES "inscope" ARE
	�, constant x � x inscope
AND	FROM � � A inscope AND � � B inscope INFER � � A�B inscope
AND	FROM � � A inscope AND � � B inscope INFER � � A�B inscope
AND	FROM � � A inscope AND � � B inscope INFER � � A�B inscope
AND	FROM � � A inscope INFER � � �A inscope
AND	FROM �, constant x � A inscope INFER � � �x.A inscope
AND	FROM �, constant x � A inscope INFER � � �x.A inscope 
END

AUTOMATCH "inscope"

