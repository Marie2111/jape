/* $Id$ */

INITIALISE applyconjectures false
INITIALISE displaystyle tree

USE "MMCS_rules.j"

CONJECTUREPANEL "Conjectures"
  THEOREM	modusponens(A,B)	IS A, A�B � B
  THEOREM	contradiction(A,B)	IS A, �A � 
END

USE "MCS+SCS_problems.j"
