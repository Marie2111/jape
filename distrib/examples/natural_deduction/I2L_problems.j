/* $Id$ */

TACTIC TheoremForward (thm) IS CUTIN (ALT thm (RESOLVE thm))

TACTIC TheoremForwardOrBackward(thm) IS
  WHEN	(LETHYP _A 
  				(ALT	(TheoremForward (WITHHYPSEL (WITHARGSEL thm)))
  						(Fail	("The theorem %s doesn't apply to the antecedent %t which you selected", thm, _A))
  				)
  			)
  			(LETHYPS _As
  				(Fail ("At present I2L Jape can't deal with multiple antecedent selections when applying theorems. Sorry.\
  						\\nCancel one of them and try again."))
  			)
  			(LETGOAL _A
				(ALT (WITHARGSEL thm) 
						(RESOLVE (WITHARGSEL thm)) 
						(TheoremForward (WITHARGSEL thm))
						(Fail	"Theorem application failed -- tell Richard")
				)
  			)
  			(LETOPENSUBGOAL G _A 
  				(Fail ("Error in I2L Jape (open subgoal in TheoremForwardOrBackward). Tell Richard."))
  			)
			(LETOPENSUBGOALS _As
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
  
  /* Panels are declared in reverse order because the GUIs,  quite reasonably, create panels in the order requested.
    * Thus the last you ask for is the last created, and appears at the front of the stack.
    */

CONJECTUREPANEL "Impossible conjectures"
	THEOREM IS E�(F�G) � (E�F)�G
	THEOREM IS (E�F)�G � (E�F)�G
	THEOREM IS (E�F)�G � E�(F�G)
	
	THEOREM IS E � E�F
	THEOREM IS E�F � E�F
	
	THEOREM IS R(j), �x.(R(x)�S(x)) � S(j)
	THEOREM IS �x.R(x)��x.S(x) � �x.(R(x)�S(x))
	THEOREM IS actual j, S(j) � �x.(R(x)�S(x))
	THEOREM IS �x.R(x)��x.S(x) � �x.(R(x)�S(x))
	THEOREM IS �x.R(x) � �x.R(x)
	
	THEOREM IS actual j, actual k, �x.R(x) � R(j)

	BUTTON Apply IS apply TheoremForwardOrBackward COMMAND
END

CONJECTUREPANEL "Classical conjectures"
	THEOREM IS	��E � E

	THEOREM IS	� E��E
	THEOREM IS	� ((E�F)�E)�E
	
	THEOREM IS	�F��E � E�F
	THEOREM IS	�(�E��F) � E�F
	THEOREM IS	�(�E��F) � E�F
	THEOREM IS	�(E�F) � �E��F
	THEOREM IS	(E�F)�(F�E)
	
	THEOREM IS	�(�x.�R(x)) � �x.R(x)
	THEOREM IS	�(�x.�R(x)) � �x.R(x)
	THEOREM IS	�(�x.R(x)) � �x.�R(x)
	
	THEOREM IS actual j, actual k � �x.(R(x)�R(j)�R(k))

	THEOREM IS	actual i, �x.(R(x)��R(x)), �(�y.�R(y)) � �z.R(z)
	
	BUTTON Apply IS apply TheoremForwardOrBackward COMMAND
END
  
CONJECTUREPANEL Conjectures
	THEOREM IS	E, E�F � F
	THEOREM IS	E�F, F�G, E � G	
	THEOREM IS	E�(F�G), E�F, E � G
	THEOREM IS	E�F, F�G � E�G
	THEOREM IS	E�(F�G) � F�(E�G)
	THEOREM IS	E�(F�G) � (E�F)�(E�G)
	THEOREM IS	E � F�E
	THEOREM IS	� E�(F�E)
	THEOREM IS	E�F � (F�G)�(E�G)
	THEOREM IS	E�(F�(G�S)) � G�(F�(E�S))
	THEOREM IS	� (E�(F�G))�((E�F)�(E�G))
	THEOREM IS	(E�F)�G � E�(F�G)

	THEOREM IS	E, F � E�F
	THEOREM IS	E�F � E
	THEOREM IS	E�F � F
	THEOREM IS	E�(F�G) � (E�F)�G
	THEOREM IS	(E�F)�G � E�(F�G)
	
	THEOREM IS	E�F � E�F
	THEOREM IS	(E�F)�(E�G) � E�(F�G)
	THEOREM IS	E�(F�G) � (E�F)�(E�G)
	THEOREM IS	E�(F�G) � (E�F)�G
	THEOREM IS	(E�F)�G � E�(F�G)
	THEOREM IS	(E�F)�G � (E�F)�G
	THEOREM IS	E�(F�G) � (E�F)�G

	THEOREM IS	E � E�F	
	THEOREM IS	F � E�F	
	THEOREM IS	E�F � F�E
	
	THEOREM IS	F�G � (E�F)�(E�G)
	THEOREM IS	E�E � E
	THEOREM IS	E � E�E
	THEOREM IS	E�(F�G) � (E�F)�G
	THEOREM IS	(E�F)�G � E�(F�G)
	
	THEOREM IS	E�(F�G) � (E�F)�(E�G)
	THEOREM IS	(E�F)�(E�G) � E�(F�G)
	THEOREM IS	E�(F�G) � (E�F)�(E�G)
	THEOREM IS	(E�F)�(E�G) � E�(F�G)
	
	THEOREM IS	(E�G)�(F�G) � (E�F)�G
	THEOREM IS	(E�F)�G � (E�G)�(F�G)

	THEOREM IS	E � ��E
	THEOREM IS	�E � E�F
	THEOREM IS	E�F � �F��E

	THEOREM IS E�F, �F � E
	THEOREM IS E�F, �E � F
		
	THEOREM IS	E�F � �(�E��F)
	THEOREM IS	E�F � �(�E��F)
	THEOREM IS	�(E�F) � �E��F
	THEOREM IS	�E��F � �(E�F)
	THEOREM IS	�E��F � �(E�F)
	THEOREM IS	 � �(E��E)
	
	THEOREM IS	E��E � F

	THEOREM IS	actual j, R(j), �x.(R(x)�S(x)) � S(j)
	THEOREM IS	�x.(R(x)�S(x)) � �x.R(x)��x.S(x)
	THEOREM IS	�x.(R(x)�S(x)), �x.(S(x)�T(x)) � �x.(R(x)�T(x))
	THEOREM IS	�x.R(x)��x.S(x) � �x.(R(x)�S(x))
	THEOREM IS	�x.(R(x)�S(x)) � �x.R(x)��x.S(x)
	THEOREM IS	�x.(R(x)�S(x)), �x.R(x) � �x.S(x)
	THEOREM IS	�x.(R(x)�S(x)) � �x.R(x)��x.S(x)
	THEOREM IS	�x.R(x)��x.S(x) � �x.(R(x)�S(x))
	THEOREM IS	�x.(R(x)�S(x)) � �x.R(x)��x.S(x)
	THEOREM IS	actual j, �x.R(x) � �x.R(x)
	THEOREM IS	�x.R(x) � �(�x.�R(x))
	THEOREM IS	�x.R(x) � �(�x.�R(x))
	THEOREM IS	�x.�R(x) � �(�x.R(x))
	THEOREM IS	�x.�R(x) � �(�x.R(x))
	THEOREM IS	�(�x.R(x)) � �x.�R(x)

	BUTTON Apply IS apply TheoremForwardOrBackward COMMAND
END
