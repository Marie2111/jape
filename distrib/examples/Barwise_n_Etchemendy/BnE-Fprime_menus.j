/* $Id$ */

TACTIC ForwardSubst (ruleLR, ruleRL,pat) IS
	WHEN
		(LETHYPSUBSTSEL _P 
			cut
			ruleRL 
			(WHEN
				(LETHYP	_Q 
					(ALT	(WITHHYPSEL hyp) 
						(JAPE (fail(the hypothesis you formula-selected wasn't a pat formula)))
					)
				)
				(JAPE (SUBGOAL 1))
			) 
			(WITHSUBSTSEL hyp)
		)
		(LETCONCSUBSTSEL _P
			(WITHSUBSTSEL ruleLR)
			(WHEN	
				(LETHYP	_Q 
					(ALT	(WITHHYPSEL hyp) 
						(JAPE (fail(the hypothesis you formula-selected wasn't a pat formula)))
					)
				)
				SKIP
			)
		)
		(JAPE (fail(please text-select one or more instances of a sub-formula to replace)))

TACTIC ForwardSubstHiding (ruleLR, ruleRL, thm) IS
	WHEN	(LETHYPSUBSTSEL
				_P 
				cut
				 (LAYOUT () (1) ruleRL thm (WITHSUBSTSEL hyp))
			)
			(LETCONCSUBSTSEL _P (LAYOUT () (1) (WITHSUBSTSEL ruleLR) thm))
			/* the next thing does some serious trickery to make it possible to influence the second argument
			  * to a rewrite rule.  It would be superseded if there were a way to provide the second argument
			  * directly.  I would like to write ruleRL _ _P.
			  */
			(LETHYP _P cut (LAYOUT () (1) ruleRL thm (LETGOAL (_P'[_x\_Q])  (WITHHYPSEL(hyp _Q)))))
			(LETGOAL _P (LAYOUT () (1) (ruleLR _P) thm))

TACTIC "�-I tac" IS WITHARGSEL "�-I"
TACTIC "�!-I tac" IS WITHARGSEL "�!-I"
TACTIC "�-E tac" IS FOB "�-E forward" 0 "�-E"
TACTIC "�-E tac" IS FOB ForwardUncut 0 "�-E"	
TACTIC "�-E tac" IS FOBSS ForwardCut 0 "�-E"
TACTIC "�-E tac" IS FOB ForwardUncut 0 "�-E"

MENU "System F�" IS
	ENTRY "�-I"	
	ENTRY "�-I"
	ENTRY "�-I"	
	ENTRY "�-I(L)" IS FOB ForwardCut 0 "�-I(L)"
	ENTRY "�-I(R)" IS FOB ForwardCut 0 "�-I(R)"
	ENTRY "�-I"
	ENTRY "�-I"
	ENTRY "�-I"
	ENTRY "�-I" IS "�-I tac"
	ENTRY "�!-I" IS "�!-I tac"
	
	SEPARATOR
	
	ENTRY "�-E"		IS "�-E tac" 
	ENTRY "�-E(L)"	IS FOB "�-E(L) forward" 0 "�-E(L)" 
	ENTRY "�-E(R)"	IS FOB "�-E(R) forward" 0 "�-E(R)" 
	ENTRY "�-E(L)"	IS FOB ForwardCut 0 "�-E(L)"
	ENTRY "�-E(R)" 	IS FOB ForwardCut 0 "�-E(R)"
	ENTRY "�-E"		IS "�-E tac"	
	ENTRY "�-E"		IS FOB ForwardCut 0 "�-E"	
	ENTRY "�-E"		IS FOB ForwardCut 0 "�-E"	
	ENTRY "�-E"		IS "�-E tac"	
	ENTRY "�-E"		IS "�-E tac"
	ENTRY "�!-E(�)"	IS FOB ForwardCut 0 "�!-E(�)"
	ENTRY "�!-E(��)"	IS FOB ForwardCut 0 "�!-E(��)"
	SEPARATOR
	ENTRY "A=A"
	ENTRY hyp		IS hyp
END

MENU "Substitution"
	ENTRY "A��"		IS ForwardSubst "rewrite � �" "rewrite � �" (�)
	ENTRY "��B"		IS ForwardSubst "rewrite � �" "rewrite � �" (�)
	ENTRY "A=�"		IS ForwardSubst "rewrite = �" "rewrite = �" (=)
	ENTRY "�=B"		IS ForwardSubst "rewrite = �" "rewrite = �" (=)
END

TACTICPANEL "Definitions" IS
	RULE "A�B � �(A=B)" IS INFER A�B � �(A=B)
	
	PREFIXBUTTON "A��" IS apply ForwardSubstHiding "rewrite � �" "rewrite � �"
	PREFIXBUTTON "��B" IS apply ForwardSubstHiding "rewrite � �" "rewrite � �"
END
