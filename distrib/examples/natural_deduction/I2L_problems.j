/* $Id$ */

TACTIC TheoremForward (thm) IS CUTIN (ALT thm (RESOLVE thm))

TACTIC TheoremForwardOrBackward(thm) IS
  WHEN	(LETHYP _P 
  				(ALT	(TheoremForward (WITHHYPSEL (WITHARGSEL thm)))
  						(Fail	("The theorem %s doesn't apply to the antecedent %t which you selected", thm, _P))
  				)
  			)
  			(LETHYPS _Ps
  				(Fail ("At present I2L Jape can't deal with multiple antecedent selections when applying theorems. Sorry.\
  						\\nCancel one of them and try again."))
  			)
  			(LETGOAL _P
				(ALT (WITHARGSEL thm) 
						(RESOLVE (WITHARGSEL thm)) 
						(TheoremForward (WITHARGSEL thm))
						(Fail	"Theorem application failed -- tell Richard")
				)
  			)
  			(LETOPENSUBGOAL G _P 
  				(Fail ("Error in I2L Jape (open subgoal in TheoremForwardOrBackward). Tell Richard."))
  			)
			(LETOPENSUBGOALS _Pgs
				(ALERT	("There is more than one unproved conclusion in the proof. Please select one � \
				 			\or select an antecedent � to show \
							\Jape where to apply the theorem.")
							("OK", STOP) 
							("Huh?", Explainantecedentandconclusionwords)
				)
			)
			(ALERT "The proof is finished -- there are no unproved conclusions left."
						("OK", STOP) ("Huh?", Explainunprovedconclusionwords)
			)
  				
/* These theorems are all stated without an explicit left context �. That is possible because, in I2L_rules.j,
  * we declared a WEAKEN structure rule: Jape will automatically discard any unmatched left-context
  * formulae.
  */
  
CONJECTUREPANEL Conjectures
	THEOREM IS	P, P�Q � Q
	THEOREM IS	P�Q, Q�R, P � R	
	THEOREM IS	P�(Q�R), P�Q, P � R
	THEOREM IS	P�Q, Q�R � P�R
	THEOREM IS	P�(Q�R) � Q�(P�R)
	THEOREM IS	P�(Q�R) � (P�Q)�(P�R)
	THEOREM IS	P � Q�P
	THEOREM IS	P�(Q�P)
	THEOREM IS	P�Q � (Q�R)�(P�R)
	THEOREM IS	P�(Q�(R�S)) � R�(Q�(P�S))
	THEOREM IS	(P�(Q�R))�((P�Q)�(P�R))
	THEOREM IS	(P�Q)�R � P�(Q�R)
	THEOREM "P�(Q�R) � (P�Q)�R NOT" IS P�(Q�R) � (P�Q)�R

	THEOREM IS	P, Q � P�Q
	THEOREM IS	P�Q � P
	THEOREM IS	P�Q � Q
	THEOREM IS	P�(Q�R) � (P�Q)�R
	THEOREM IS	(P�Q)�R � P�(Q�R)
	
	THEOREM IS	P�Q � P�Q
	THEOREM IS	(P�Q)�(P�R) � P�(Q�R)
	THEOREM IS	P�(Q�R) � (P�Q)�(P�R)
	THEOREM IS	P�(Q�R) � (P�Q)�R
	THEOREM IS	(P�Q)�R � P�(Q�R)
	THEOREM IS	(P�Q)�R � (P�Q)�R
	THEOREM "(P�Q)�R � (P�Q)�R NOT" IS (P�Q)�R � (P�Q)�R
	THEOREM IS	P�(Q�R) � (P�Q)�R
	THEOREM "(P�Q)�R � P�(Q�R) NOT" IS (P�Q)�R � P�(Q�R)

	THEOREM IS	P � P�Q	
	THEOREM IS	Q � P�Q	
	THEOREM IS	P�Q � Q�P
	
	THEOREM IS	Q�R � (P�Q)�(P�R)
	THEOREM IS	P�P � P
	THEOREM IS	P � P�P
	THEOREM IS	P�(Q�R) � (P�Q)�R
	THEOREM IS	(P�Q)�R � P�(Q�R)
	
	THEOREM IS	P�(Q�R) � (P�Q)�(P�R)
	THEOREM IS	(P�Q)�(P�R) � P�(Q�R)
	THEOREM IS	P�(Q�R) � (P�Q)�(P�R)
	THEOREM IS	(P�Q)�(P�R) � P�(Q�R)
	
	THEOREM IS	(P�R)�(Q�R) � (P�Q)�R
	THEOREM IS	(P�Q)�R � (P�R)�(Q�R)

	THEOREM IS	��P�P
	THEOREM IS	P � ��P
	
	THEOREM IS	P�Q � �Q��P
	THEOREM IS	�Q��P � P�Q

THEOREM IS P�Q, �Q � P
THEOREM IS P�Q, �P � Q
	
THEOREM IS	P�Q � �(�P��Q)
	THEOREM IS	�(�P��Q) � P�Q
	THEOREM IS	P�Q � �(�P��Q)
	THEOREM IS	�(�P��Q) � P�Q
	THEOREM IS	�(P�Q) � �P��Q
	THEOREM IS	�P��Q � �(P�Q)
	THEOREM IS	�(P�Q) � �P��Q
	THEOREM IS	�P��Q � �(P�Q)
	THEOREM IS	 � �(P��P)
	
	THEOREM IS	(P�Q)�(Q�P)
	THEOREM IS	P��P � Q

	THEOREM IS	P��P
	THEOREM IS	((P�Q)�P)�P

	THEOREM IS	actual c, P(c), �x.(P(x)�Q(x)) � Q(c)
	THEOREM	"P(c), �x.(P(x)�Q(x)) � Q(c) NOT" IS P(c), �x.(P(x)�Q(x)) � Q(c)
	THEOREM IS	�x.(P(x)�Q(x)) � �x.P(x)��x.Q(x)
	THEOREM	"�x.P(x)��x.Q(x) � �x.(P(x)�Q(x)) NOT" IS �x.P(x)��x.Q(x) � �x.(P(x)�Q(x))
	THEOREM IS	�x.(P(x)�Q(x)), �x.(Q(x)�R(x)) � �x.(P(x)�R(x))
	THEOREM	"actual c, Q(c) � �x.(P(x)�Q(x)) NOT" IS actual c, Q(c) � �x.(P(x)�Q(x))
	THEOREM IS	�x.P(x)��x.Q(x) � �x.(P(x)�Q(x))
	THEOREM IS	�x.(P(x)�Q(x)) � �x.P(x)��x.Q(x)
	THEOREM IS	�x.(P(x)�Q(x)), �x.P(x) � �x.Q(x)
	THEOREM IS	�x.(P(x)�Q(x)) � �x.P(x)��x.Q(x)
	THEOREM	"�x.P(x)��x.Q(x) � �x.(P(x)�Q(x)) NOT" IS �x.P(x)��x.Q(x) � �x.(P(x)�Q(x))
	THEOREM IS	�x.P(x)��x.Q(x) � �x.(P(x)�Q(x))
	THEOREM IS	�x.(P(x)�Q(x)) � �x.P(x)��x.Q(x)
	THEOREM IS	actual c, �x.P(x) � �x.P(x)
	THEOREM	"�x.P(x) � �x.P(x) NOT" IS �x.P(x) � �x.P(x)
	THEOREM IS	�x.P(x) � �(�x.�P(x))
	THEOREM IS	�(�x.�P(x)) � �x.P(x)
	THEOREM IS	�x.P(x) � �(�x.�P(x))
	THEOREM IS	�(�x.�P(x)) � �x.P(x)
	THEOREM IS	�(�x.P(x)) � �x.�P(x)
	THEOREM IS	�x.�P(x) � �(�x.P(x))
	THEOREM IS	�(�x.P(x)) � �x.�P(x)
	THEOREM IS	�x.�P(x) � �(�x.P(x))

	BUTTON Apply IS apply TheoremForwardOrBackward COMMAND
END
