/* $Id$ */

TACTIC TheoremForwardOrBackward(thm) IS
  WHEN (LETHYP _P cut (WITHSELECTIONS thm)) thm
  
/* These theorems are all stated without an explicit left context �. That is possible because, in ItL_rules.j,
  * we declared a WEAKEN structure rule: Jape will automatically discard any unmatched left-context
  * formulae.
  */
  
CONJECTUREPANEL Conjectures
  THEOREMS NaturalDeductionConjectures ARE
  		P, P � Q � Q
  AND	P � Q, Q � R , P � R	
  AND	P � (Q � R), P � Q, P � R
  AND	P � Q, Q � R � P � R
  AND	P � (Q � R) � Q � (P � R)
  AND	P � (Q � R) � (P � Q) � (P � R)
  AND	P � Q � P
  AND	� P � (Q � P)
  AND	P � Q � (Q � R) � (P � R)
  AND	P � (Q � (R � S)) � R � (Q � (P � S ))
  AND	� (P � (Q � R)) � ((P � Q) � (P � R))
  
  AND	P, Q � P � Q
  AND	P � Q � P
  AND	P � Q � Q
  AND	(P � Q) � R � P � (Q � R)
  AND	P � (Q � R) � (P � Q) � R
  
  AND	P � P � Q	
  AND	Q � P � Q	
  
  AND	P � Q � Q � P
  AND	Q � R � (P � Q) � (P � R)
  AND	P � P � P
  AND	P � P � P
  AND	P � (Q � R) � (P � Q) � R
  AND	(P � Q) � R � P � (Q � R)
  AND	P � (Q � R) � (P � Q) � (P � R)
  AND	(P � Q) � (P � R) � P � (Q � R)
  AND	P � (Q � R) � (P � Q) � (P � R)
  AND	(P � Q) � (P � R) � P � (Q � R)
  AND	P � R, Q � R � (P � Q) � R 
  
  AND	� � �P � P
  AND	P � � �P
  AND	P � Q � �Q � �P
  AND	�Q � �P � P � Q
  AND	� P � �P
  AND	P � Q � �(�P � �Q)
  AND	�(�P � �Q) � P � Q
  AND	P � Q � �(�P � �Q)
  AND	�(�P � �Q) � P � Q
  AND	�(P � Q) � �P � �Q
  AND	�P � �Q � �(P � Q)
  AND	�(P � Q) � �P � �Q
  AND	�P � �Q � �(P � Q)
  AND	� �(P � �P)
  AND	Q � P, P � R � Q � R
  AND	� (P � Q) � (Q � P)
  AND	P � �P � Q
  AND	� ((P � Q) � P) � P
  
  AND	P(c), �x.(P(x) � Q(x)) � Q(c)
  AND	�x.P(x) � Q(x) � (�x.P(x)) � (�x.Q(x))
  AND	�x.P(x) � Q(x), �x.Q(x) � R(x) � �x.P(x) � R(x)
  AND	(�x.P(x)) � (�x.Q(x)) � �x.P(x) � Q(x)
  AND	�x.P(x) � Q(x) � (�x.P(x)) � (�x.Q(x))
  AND	�x.P(x) � �x.P(x)
  AND	�x.P(x) � Q(x), �x.P(x) � �x.Q(x)
  AND	�x.P(x) � Q(x) � (�x.P(x)) � (�x.Q(x))
  AND	(�x.P(x)) � (�x.Q(x)) � �x.P(x) � Q(x)
  AND	�x.P(x) � Q(x) � (�x.P(x)) � (�x.Q(x))
  AND	�x.P(x) � �(�x. �P(x))
  AND	�(�x. �P(x)) � �x.P(x)
  AND	�x.P(x) � �(�x. �P(x))
  AND	�(�x. �P(x)) � �x.P(x)
  AND	�(�x.P(x)) � �x. �P(x)
  AND	�x. �P(x) � �(�x.P(x))
  AND	�(�x.P(x)) � �x. �P(x)
  AND	�x. �P(x) � �(�x.P(x))
  END
  
  THEOREM "(�x.P(x)) � (�x.Q(x)) � �x.P(x) � Q(x) NOT" IS (�x.P(x)) � (�x.Q(x)) � �x.P(x) � Q(x)
  THEOREM "(�x.P(x)) � (�x.Q(x)) � �x.P(x) � Q(x) NOT" IS (�x.P(x)) � (�x.Q(x)) � �x.P(x) � Q(x)
  
  PREFIXBUTTON Apply IS apply TheoremForwardOrBackward
END
