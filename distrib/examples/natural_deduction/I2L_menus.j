/* $Id$ */

/* ******************** remains of the old 'choose by selection' mechanism, which is dead but may fly again ******************** */

TACTIC ForwardOrBackward (Forward, n, Rule) IS 
	WHEN	(LETHYP _Ph 
					(ALT	(Forward n Rule)
								(WHEN	(LETARGSEL _Q  (Fail (Rule is not applicable to antecedent ' _Ph ' with argument ' _Q ')))
											(Fail (Rule is not applicable to antecedent ' _Ph '))
								)
					)
				)
				(ALT	(WITHSELECTIONS Rule)
						(WHEN	(LETARGSEL _Ph (Fail (Rule is not applicable with argument ' _Ph ')))
							(Fail (Rule is not applicable))
						)
				)

/* ******************** tactics to apply rules pseudo-forwards ******************** */

TACTIC ForwardCut (n,rule)
	CUTIN (ForwardUncut n rule)

TACTIC ForwardUncut (n,Rule)
	WHEN	(LETHYP _Ph 
					(LETGOALPATH G (WITHARGSEL Rule) (GOALPATH (SUBGOAL G n)) (WITHHYPSEL hyp) (GOALPATH G) NEXTGOAL)
				)
				/* If LETHYP fails at this point, we had better have a singleton LHS.*/
				(LETLHS _Ph
					(LETGOALPATH G (WITHARGSEL Rule) (GOALPATH (SUBGOAL G n)) 
					(LETGOAL _Pg 
						(ALT (UNIFY _Pg _Ph) (Fail ("Error in I2L Jape (can't unify lhs %t with rhs %t in ForwardUncut). Tell Richard.", _Ph, _Pg)))
						(ANY hyp)
					) (GOALPATH G) NEXTGOAL)
				)
				(Fail "Error in I2L Jape (ForwardUncut falls through). Tell Richard.")

/* ******************** tactics to deal with variables in quantification rules ******************** */

TACTIC "� elim forward" IS
	WHEN	(LETHYP2 (actual _c) (�_x._P) ("� elim forward step" (�_x._P)))
				(LETHYP (�_x._P) ("� elim forward moan" ("You only selected %t.", �_x._P)))
				(LETHYP (actual _c) ("� elim forward moan" ("You only selected %t.", actual _c)))
				(LETHYPS _Ps ("� elim forward moan" ("You selected %l.", (_Ps, ", ", " and "))))
				(LETGOAL (�_x._P)
					(ALERT ("To make a � elim step forward, you must select an antecedent of the form �x.A, and \
								\also a pseudo-assumption of the form actual c. You didn't select any antecedents, but the \
								\current conclusion is %t, which could be used to make a � intro step backwards.\
								\\nDid you perhaps mean to make a backward step with � intro?", �_x._P)
								("OK",STOP) ("Huh?",SEQ Explainantecedentandconclusionwords STOP)
					)
				)
				("� elim forward moan" "You didn't select any antecedents")
			
TACTIC "� elim forward step" (P) IS
	Noarg	(CUTIN 
					(LAYOUT "� elim" (0) "� elim")
					(WITHHYPSEL (hyp P))
					(WITHHYPSEL "inscope")
				)

TACTIC "� elim forward moan" (extra) IS
	ALERT	("To make a � elim step forward, you must select an antecedent of the form �x.A, and \
				\also a pseudo-assumption of the form actual c.%s",extra)
				("OK", STOP) ("Huh?", SEQ Explainvariables STOP)

TACTIC "� elim forward" IS
	ForwardUncut 0 "� elim"
	
TACTIC "� intro backward" IS  
	WHEN	(LETCONC (�_x._P)
					("� intro backward hypcheck" "� intro backward step" ("You selected the conclusion %t (which is ok), but ", �_x._P))
				)
				(LETCONC _P
					("� intro backward selection moan" (" You selected the conclusion %t.", _P))
				)
				(LETGOAL (�_x._P)
					("� intro backward hypcheck" "� intro backward step" ("The conclusion is %t (which is ok), but", �_x._P))
				)
				(LETGOAL _P /* the wrong goal, sob */
					("� intro backward selection moan" (" The conclusion you are working on is %t.", _P))
				)
				(LETOPENSUBGOAL G (�_x._P) /* there is something they might have chosen */
					("� intro backward hypcheck" 
						(ALERT ("To make an � intro step backwards, you have to use a conclusion of the form \
									\�x.A, and select a pseudo-assumption of the form actual c. You selected the \
									\pseudo-assumption, but you didn't click on the conclusion %t. Would you like to proceed \
									\with the step using %t?\
									\\n\n(You can avoid this message in the future if you always click on the relevant \
									\conclusion before you make the step.)", �_x._P, �_x._P)
									("OK", SEQ (GOALPATH G) "� intro backward step")  ("Huh?", SEQ Explainvariables STOP) ("Cancel", STOP)
						)
						("You didn't select the unproved conclusion %t, and", �_x._P))
				)
				("� intro backward hypcheck" ("� intro backward selection moan" " You didn't make any conclusion selection.") 
					("You didn't make any conclusion selection, and ")
				)

TACTIC "� intro backward step" (c) IS
	Noarg	(SEQ
					(LAYOUT "� intro" (0) ("� intro" c))
					fstep 
					(WITHHYPSEL "inscope")
				)
				"� intro"

TACTIC "� intro backward selection moan" (stuff) IS
	ALERT ("To make an � intro step backwards, you have to use a conclusion of the form \
				\�x.A, and select a pseudo-assumption of the form actual c.%s", stuff)
				("OK", STOP) ("Huh?", SEQ Explainvariables STOP)

TACTIC "� intro backward hypcheck" (action, gmess) IS
	WHEN	(LETHYP (actual _c) (action _c)) /* the right antecedent - hoorah! */
				(LETHYP (�_x._P) /* looks like a forward step */
					(ALERT ("To make an � intro step backwards, you have to select a conclusion of the form \
								\�x.A, and a pseudo-assumption of the form actual c. You selected \
								\the antecedent %t, which would fit � elim going forward.\
								\\nWould you like to make the forward step instead?",�_x._P)
								("Forward", "� elim forward") ("Huh?", SEQ Explainvariables STOP) ("Cancel", STOP)
					)
				)
				(LETHYP _P /* the wrong antecedent */
					("� intro backward selection moan" ("%s you selected the antecedent %t instead.", gmess, _P))
				)
				(LETHYPS _Ps /* more than one */
					("� intro backward selection moan" ("%s you selected more than one antecedent � %l.", gmess, (_Ps, ", ", " and ")) )
				)
				("� intro backward selection moan" ("%s you didn't select an antecedent.", gmess))

TACTIC Qstep (pre, rule, post, stepname, arg) IS
	SEQ
		pre
		(LAYOUT stepname (0) (WITHARGSEL rule)) 
		post
		(ALT (WITHARGSEL "inscope" )
				(ALERT	("You've made a mistake with variable scopes.\
							\\n\nYou can't make a %s step using the variable %t, \
							\because the current conclusion %t isn't in the scope of a \
							\pseudo-assumption �actual %t�.", stepname, arg, _P, arg)
							("OK", STOP) ("Huh?", SEQ Explainvariables STOP)
				)
		)
	
TACTIC Failvar (stepname) IS
	ALERT	("To make a %s step, you must text-select an in-scope instance of a variable -- \
				\a name following 'actual' somewhere in the proof.", stepname)
				("OK", STOP) ("Huh?", SEQ Explainvariables STOP)

TACTIC FailWrongvar (stepname, arg) IS
	ALERT	("To make a %s step, you must text-select an in-scope instance of a variable -- \
				\a name (like c or c1 or something like that) following 'actual' somewhere in the proof.\
				\\n\nYou text-selected �%s�, which isn't a variable.", stepname, arg)
				("OK", STOP) ("Huh?", SEQ Explainvariables STOP)

/* ******************** most rules don't want arguments ******************** */

TACTIC Noarg (rule, stepname) IS
	WHEN	(LETARGTEXT arg 
					(ALERT	("The %s rule doesn't need an argument, but you text-selected %s. \
								\Do you want to go on with the step, ignoring the text-selection?", stepname, arg)
								("OK", rule)
								("Cancel", STOP)
					)
				)
				rule

TACTIC SingleorNoarg (rule, stepname) IS 
	WHEN	(LETARGSEL _P (WITHARGSEL rule))
				(LETMULTIARG _Ps 
					(ALERT ("The %s rule can accept a single argument. You text-selected %l, which is more than \
								\it can deal with. Cancel some or all of your text selections and try again.", stepname, _Ps)
								("OK", STOP)
					)
				)
				rule

/* ******************** tactics for rules that only work backwards ******************** */

TACTIC BackwardOnlyA (pattern, action, stepname, shape) IS BackwardOnly pattern action stepname shape "only makes sense working backwards"

TACTIC BackwardOnlyB (pattern, action, stepname, shape) IS BackwardOnly pattern action stepname shape "doesn't work backwards in I2L Jape yet"

TACTIC BackwardOnlyC (pattern, action, stepname, shape) IS BackwardOnly pattern action stepname shape "can also be used forward -- see the Forward menu"

MACRO BackwardOnly (pattern, action, stepname, shape, explain) IS
	WHEN	(LETGOAL pattern 
					(WHEN	(LETHYP _Ph (BackwardOnly2 stepname action explain _Ph))
								(WITHSELECTIONS action)
					)
				)
				(LETGOAL _P (FailBackwardWrongGoal stepname shape))
				(ComplainBackward pattern stepname shape)

TACTIC BackwardOnly2 (stepname, action, explain, _Ph) IS /* oh for a binding mechanism other than tactic application ... */
	WHEN	(LETCONC _Pc (BackwardOnly3 stepname action explain _Ph _Pc ", selecting"))
				(LETRHS _Pc  /* can't fail */(BackwardOnly3 stepname action explain _Ph _Pc " from"))

TACTIC BackwardOnly3 (stepname, action, explain, _Ph, _Pc, stuff) IS /* Oh for tactic nesting ... */
	(ALERT ("You asked for a backward step with the %s rule%s the conclusion %s, \
				 \but you also selected the antecedent %s. \
				 \\n\nThe %s rule %s. \
				 \ \n\nDo you want to go on with the backward step from %s -- ignoring %s?", 
				stepname, stuff,  _Pc, _Ph, stepname, explain, _Pc, _Ph)
				("Backward", action) STOP
	)

TACTIC FailBackwardWrongGoal (stepname, shape) IS
	WHEN	(LETCONC _Pc (FailBackwardWrongGoal2 stepname shape _Pc "You selected"))
				(LETRHS _Pc (FailBackwardWrongGoal2 stepname shape _Pc "The current conclusion is"))

TACTIC FailBackwardWrongGoal2 (stepname, shape, Pc, stuff) IS	
	ALERT	("To make a backward step with %s, the conclusion must be of the form %s. \
				\\n%s %s, which isn't of that form.", stepname, shape, stuff, Pc)
				("OK", STOP) ("Huh?", SEQ Explainantecedentandconclusionwords STOP )

/* ******************** tactic for rules that swing either way ******************** */

TACTIC BackwardPreferred (bpat, bact, fpat, fact, stepname, shape) IS
	WHEN	(LETGOAL bpat
					(WHEN	(LETHYP _Ph 
									(WHEN	(LETCONC _Pc (BackwardPreferredWithHyp bact fpat fact stepname shape _Ph _Pc ", selecting"))
												(LETGOAL _Pc  (BackwardPreferredWithHyp bact fpat fact stepname shape _Ph _Pc " from"))
									)
								)
								(WITHSELECTIONS bact)
					)
				)
				(LETGOAL _P (FailBackwardWrongGoal stepname shape))
				(ALERT "whoops! BackwardPreferred")
				
TACTIC BackwardPreferredWithHyp (bact, fpat, fact, stepname, shape, Ph, Pc, explaingoal) IS
	WHEN	(LETHYP fpat
					(ALERT ("You asked for a backward step with the %s rule%s the conclusion %t, \
								 \but you also selected the antecedent %t. \
								 \\n\nSelecting an antecedent is only useful if you want to make a forward step. \
								 \You can apply the rule forward from %t if you like, because the rule fits that antecedent.\
								 \ \n\nDo you want to go on with the backward step from %t -- ignoring %t -- \
								 \or do you want to try a forward step from %t?", 
								stepname, explaingoal,  Pc, Ph, Ph, Pc, Ph, Ph)
								("Backward", bact) ("Forward", fact) STOP
					)
				)
				(ALERT ("You asked for a backward step with the %s rule%s the conclusion %t, \
							 \but you also selected the antecedent %t. \
							 \\n\nSelecting an antecedent is only useful if you want to make a forward step, \
							 \and you couldn't go forward from %t with %s, because it doesn't match the rule.\
							 \ \n\nDo you want to go on with the backward step from %t -- ignoring %t -- \
							 \or do you want to try a forward step from %t?", 
							stepname, explaingoal,  Pc, Ph, Ph, stepname, Pc, Ph, Ph)
							("Backward", bact) STOP
				)

/* ******************** tactics to deal with bad backward selections ******************** */

MACRO ComplainBackward (pattern, stepname, shape) IS
	WHEN	(LETCONC pattern /* dead conclusion, right shape */
					(LETCONC _Pc
						(ALERT	("You selected the already-proved conclusion %t.\
									\\nTo make a backward step with %s, select an unproved conclusion.", _Pc, stepname)
									("OK", STOP) ("Huh?", Explainunprovedconclusionwords)
						)
					)
				)
				(LETCONC _Pc /* dead conclusion, wrong shape */
					(FailBackwardWrongGoal stepname shape)
				)
				(LETHYP _Ph
					(ALERT	("You selected the antecedent %t.\n\
								\To make a backward %s step, select an unproved conclusion of the \
								\form %s, and don't select an antecedent.", _Ph, stepname, shape)
								("OK", STOP) ("Huh?", Explainantecedentandconclusionwords)
					)
				)
				(LETOPENSUBGOAL G _Pg
					(Fail	("Error in I2L Jape (open subgoal in ComplainBackward). Tell Richard."))
				)
				(LETOPENSUBGOALS _Pgs
					(ALERT	("There is more than one unproved conclusion. Please select one to show \
								\Jape where to apply the %s step.", stepname)
								("OK", STOP) 
								("Huh?", Fail	("The unproved conclusions (formulae below a line of dots) in your proof \
													\are %l.\nSelect one of them to tell Jape where to make the %s step.",
													(_Pgs,", "," and "), stepname)
								)
					)
				)
				(ALERT "The proof is finished -- there are no unproved conclusions left."
							("OK", STOP) ("Huh?", Explainunprovedconclusionwords)
				)

/* ******************** special one for hyp ******************** */

TACTIC "try hyp" (Ph, Pg, mess) IS
	SEQ	(ALT (UNIFY Ph Pg)
					(BADUNIFY X Y (ALERT ("%s, because the formula structures don't match.", mess) ("OK", STOP)))
					(BADMATCH X Y (ALERT ("%s, because to do so would change the proof (you shouldn't see this message).", mess) ("OK", STOP)))
					(BADPROVISO X Y P 
						(ALERT ("%s, because to do so would smuggle a variable out of its scope \
									\(see the proviso %s in the proviso pane).", mess, P)
									("OK", STOP)
									("Huh?", (ALERT "The proviso c NOTIN _B (for example) appears when the unknown _B occurs both inside \
															\AND outside the scope box for c. It means that nothing unified with _B can contain \
															\the variable c, because that would produce an occurrence of c outside its scope box."
															("OK", STOP)
												)
									)
						) 
					)
			)
			(ALT (WITHHYPSEL hyp)	
					(ALERT "I2L Jape error (hyp failed in hyptac). Tell Richard" ("OK", STOP))
			)

TACTIC hyptac IS
	WHEN	(LETHYP _Ph /* demand antecedent selection to avoid multi-hyp messages ... */
					(WHEN	(LETCONC _Pg ("try hyp" _Ph _Pg ("%t and %t don't unify", _Ph, _Pg)))
								(LETOPENSUBGOAL G _Pg 
									/* shall we just do it if we can? */
									(GOALPATH G) 
									("try hyp" _Ph _Pg 
													("%t and %t (the only relevant unproved conclusion) don't unify", _Ph, _Pg)
									)
								)
								(LETOPENSUBGOALS _Pgs
									(ALERT ("Please select one of the unproved conclusions %l to unify with the antecedent %t.", 
												(_Pgs, ", ", " or "), _Ph) ("OK", STOP) ("Huh?", SEQ Explainantecedentandconclusionwords STOP )
									)
								)
								(ALERT ("There aren't any unproved conclusions relevant to the antecedent %t.", _Ph)
											("OK", STOP) ("Huh?", SEQ Explainantecedentandconclusionwords STOP )
								)
					)
				)
				(LETGOAL _Pc 
					(WHEN (LETLHS ()
									(ALERT ("You can't use hyp to prove %t, because there aren't any relevant antecedents.", _Pc)
												("OK", STOP) ("Huh?", SEQ Explainantecedentandconclusionwords STOP )
									)
								)
								(ALERT	("Please select an antecedent to unify with the conclusion %s.", _Pc)
											("OK", STOP) ("Huh?", SEQ Explainantecedentandconclusionwords STOP )
								)
					)
				)
				(ALERT "To use hyp, you have to select a conclusion and an antecedent. You didn't select anything"
							("OK", STOP) ("Huh?", SEQ Explainantecedentandconclusionwords STOP )
				)
				
/* ******************** the Backward menu ******************** */

MENU Backward IS
	ENTRY	"� intro (makes assumption)"	IS BackwardOnlyA (QUOTE (_P�_Q)) (Noarg "� intro" "� intro") "� intro" "A�B"
	ENTRY	"� intro"									IS BackwardOnlyC (QUOTE (_P�_Q)) (Noarg "� intro backward" "� intro") "� intro"  "A�B"
	ENTRY	"� intro (preserving left)"			IS BackwardOnlyC (QUOTE (_P�_Q)) (Noarg (LAYOUT "� intro" (0) "� intro(L)" fstep) "� intro") "� intro" "A�B"
	ENTRY	"� intro (preserving right)"		IS BackwardOnlyC (QUOTE (_P�_Q)) (Noarg (LAYOUT "� intro" (0) "� intro(R)" fstep) "� intro") "� intro" "A�B"
	ENTRY	"� intro (makes assumption A)"	IS BackwardOnlyA (QUOTE (�_P)) (WITHARGSEL "� intro") "� intro" "�A" 
	ENTRY	"� intro (invents formulae)"	IS 
		WHEN 
			(LETHYP2 _P (�_P) 
				(ALERT	("To make a backward step with � intro you don't have to select any antecedents. \
							\You selected %t and %t, which would fit a forward step. Since it works better \
							\that way, would you like to use � intro going forward?", _P, �_P)
							("Forward", "� intro forward") ("Cancel", STOP)
				)
			)
			(BackwardOnlyC � (SEQ (SingleorNoarg "� intro" "� intro") fstep fstep) "� intro" "�")
	ENTRY	"� intro (introduces variable)"	IS BackwardOnlyA (QUOTE (�_x._P)) (Noarg "� intro" "� intro") "� intro" "�x.A" 
	ENTRY	"� intro (needs variable)"			"� intro backward"
		
	SEPARATOR
	
	ENTRY	"� elim (constructive)"	IS BackwardOnlyA (QUOTE _P) (Noarg "� elim (constructive)" "� elim (constructive)") "� elim (constructive)" "A"
	ENTRY	"� elim (classical; makes assumption �A)"	IS BackwardOnlyA (QUOTE _P) (Noarg "� elim (classical)" "� elim (classical)") "� elim (classical)" "A"

	SEPARATOR
	ENTRY	hyp 	IS Noarg hyptac hyp
END
	
MACRO trueforward(tac) IS
	LETGOAL _A (CUTIN (LETGOAL _B (UNIFY _A _B) tac)) (ANY (MATCH hyp))
		
TACTIC fstep IS
	ALT (ANY (MATCH hyp)) (trueforward SKIP) /* avoid nasty 'hyp matches two ways', I hope */
	
TACTIC "� intro backward" IS
	WHEN	(LETGOAL (_P�_Q) /* bound to work, surely? */
					"� intro" fstep fstep
				)
				(ALERT "� intro backward tactic failed. Tell Richard.")
				
/* ******************** tactics to check that a rule can be applied forward ******************** */

TACTIC Forward (fpat, action, frule, brule, shape) IS 
	Forward2 fpat  action  fpat  frule  brule  shape 

MACRO Forward2 (fpat, action, bpat, frule, brule, shape) IS
	WHEN	(LETHYP fpat action)
				(LETLHS fpat action) /* why not? */
				(LETHYP _Ph (FailForwardWrongHyp frule shape _Ph))
				(FailForward bpat frule brule (" of the form %s", shape))

MACRO FailForward (bpat, frule, brule, explainhyp) IS
	WHEN	(LETGOAL bpat 
					(WHEN	(LETCONC _Pc (FailForwardButBackwardPoss frule brule explainhyp ("You did select the conclusion formula %s", _Pc))) 
								(FailForwardButBackwardPoss frule brule  explainhyp ("The current conclusion formula is %s", bpat))
					)
				)
				(FailForwardNoHyp frule explainhyp "")

TACTIC FailForwardButBackwardPoss (frule, brule, explainhyp, explainconc) IS
	FailForwardNoHyp frule explainhyp 
			("\n\n(%s, which would fit %s backwards -- did you perhaps mean to work backwards?)", explainconc, brule)

TACTIC FailForwardWrongHyp (stepname, shape, Ph) IS
	ALERT	("To make a forward step with %s you must select something of the form %s. \
				\\nYou selected %s, which isn't of that form.", stepname, shape, Ph)
				("OK", STOP) 

TACTIC FailForwardNoHyp (stepname, explainhyp, extra) IS
	ALERT	("To make a forward step with %s you must select a formula to work forward from.\
				\\nYou didn't.%s", stepname, extra)
				("OK", STOP) ("Huh?", SEQ ExplainClicks STOP )

/* ******************** special one for rules which don't care about antecedent shape  ******************** */

TACTIC "� introforward" (rule) IS
	WHEN	(LETHYP _P (ForwardCut 0 (LAYOUT "� intro" (0) (WITHARGSEL rule))))
				(FailForwardNoHyp "� intro" "" "")

TACTIC "� intro forward"  IS
	WHEN	(LETHYP2 _P _Q
					(ALERT ("� intro going forward is visually ambiguous � that is, it can be carried out either way round. \
					             \\nDo you want to\n\
					             \\n(a)    Make %t�%t, or \
					             \\n(b)    Make %t�%t.", _P, _Q, _Q, _P)
					             ("(a)", (CUTIN	"� intro" (ANY (WITHHYPSEL (hyp _P))) (ANY (WITHHYPSEL (hyp _Q)))))
					             ("(b)", (CUTIN	"� intro" (ANY (WITHHYPSEL (hyp _Q))) (ANY (WITHHYPSEL (hyp _P)))))
					             ("Cancel", STOP)
					)
				)
				(LETHYP _P 
					(ALERT	("To make a forward step with � intro, it's necessary to select TWO antecedent formul� to combine. \
								\You only selected %t.", _P)
								("OK", STOP) ("Huh?", SEQ ExplainClicks STOP )
					)
				) 
				(LETHYPS _Ps 
					(ALERT	("To make a forward step with � intro, it's necessary to select only two antecedent formul� to combine. \
								\You selected %l.", (_Ps, ", ", " and "))
								("OK", STOP) ("Huh?", SEQ ExplainClicks STOP )
					)
				) 
				(LETGOAL (_P�_Q)
					(ALERT	("To make a forward step with � intro, it's necessary to select TWO antecedent formul� to combine. \
								\You didn�t select any at all.\
								\\n\nHowever, the current conclusion %t would fit � intro going backwards. Did you perhaps mean to \
								\make a backward step?", _P�_Q)
								("OK", STOP) ("Huh?", SEQ ExplainClicks STOP )
					)
				)
				(ALERT	("To make a forward step with � intro, it's necessary to select TWO antecedent formul� to combine. \
							\You didn�t select any at all.")
							("OK", STOP) ("Huh?", SEQ ExplainClicks STOP )
				)

/* TACTIC "� intro forward(L)"(arg) IS 
	ForwardCut 0 ("� intro"[B\arg])

TACTIC "� intro forward(R)"(arg) IS 
	ForwardCut 0 ("� intro"[A\arg])
*/

/* this tactic is so horrible gesturally (although it works) that I've taken it out of the Forward menu */
TACTIC "� intro forward" IS
	WHEN	(LETHYP (actual _c)
					(WHEN
						(LETHYPSUBSTSEL (_P[_x\_c1]) 
							("� intro forward checkvar" _c _c1) 
							("� intro forward complain" 
								(" (you only selected actual %t)", _c) 
								(" (as you did). Sorry to be so fussy, but please click on %t and try again", _P[_x\_c1])
							)
						)
						("� intro forward checktextsel" (" (you only selected actual %t)", _c))
					)
				)
				(LETHYP _P
					("� intro forward checktextsel" (" (you selected %t)", _P))
				)
				(LETHYP2 (actual _c) _P
					(WHEN
						(LETHYPSUBSTSEL (_P1[_x\_c1])
							("� intro forward checksamehyp" _P (_P1[_x\_c1]) _c1)
							("� intro forward checkvar" _c _c1) 
							("� intro forward doit" _P _x _c1 )
						)
						("� intro forward checktextsel" " (as you did)")
					)
				)
				(LETHYPS _Ps
					("� intro forward checktextsel" (" (you selected %l)", _Ps))
				)
				("� intro forward checktextsel" " (you didn't select any antecedents)")

TACTIC "� intro forward checktextsel" (varstuff) IS
	WHEN	(LETHYPSUBSTSEL (_P[_x\_c1]) 
					("� intro forward complain" varstuff " (as you did)")
				)
				(LETHYPSUBSTSEL (_P[_x\_Q]) 
					("� intro forward complain" varstuff (" (your text-selection %t isn't a variable)", _Q))
				)
				(LETSUBSTSEL (_P[_x\_Q]) 
					("� intro forward complain" varstuff (" (your text-selection %t isn't in an antecedent)", _Q))
				)
				(LETARGTEXT c
					("� intro forward complain" varstuff (" (your text-selection %s isn't a subformula)", c))
				)
				(SEQ
					("� intro forward complain" varstuff (" (you didn't text-select anything, or you text-selected several different things)"))
				)

MACRO "� intro forward checksamehyp" (h, sel, c) IS
	WHEN	(LETMATCH h sel SKIP)
				("� intro forward complain" " (as you did)" (" (your text selection %t isn't inside the antecedent %t)", c, h))

MACRO "� intro forward checkvar"(c,c1) IS
	WHEN	(LETMATCH c c1 SKIP)
				("� intro forward complain" (" (you selected actual %t)", c) (" (you text-selected instance(s) of %t, which doesn't match %t)", c1, c))

MACRO "� intro forward doit" (P1,x1,c1) IS
	(CUTIN (LAYOUT "� intro" (0) "� intro") (WITHSUBSTSEL hyp) (WITHHYPSEL "inscope"))

TACTIC "� intro forward complain"(varstuff, selstuff) IS
	SEQ
		(ALERT	("To make an � intro step forward you have to select an assumption like actual c and also \
					\an antecedent formula in its scope%s,\
					\and text-select instances of the variable in that formula%s.",
					varstuff, selstuff)
		)
		STOP
				
/* ******************** messages about bad forward selections ******************** */

TACTIC BadForward (pattern, stepname, shape) IS 
	BadForward2 pattern stepname shape (" of the form %s", shape)

MACRO BadForward2(pattern, stepname, shape, stuff) IS
	WHEN	(LETHYP pattern /* right antecedent, other things wrong */ 
					BadForward3 pattern stepname shape stuff
				)
				(LETHYP _Ph /* wrong antecedent, other things wrong as well */
					(FailForwardWrongHyp stepname shape _Ph)
				)
				/* no antecedent at all -- just complain about that */
				(FailForwardNoHyp stepname stuff "")

TACTIC BadForward3(sel, stepname) IS
	WHEN	(LETOPENSUBGOALS _Pgs
					(ALERT ("There is more than one unproved conclusion (formula below a line of dots) \
								\associated with the antecedent %t. \
								\\nSelect one of them (%l) before you make a forward step.", sel, (_Pgs, ", ", " or "))
								("OK", SKIP) ("Huh?", ExplainHypMulti stepname sel)
					)
				)
				(LETOPENSUBGOAL G _Pg
					(ALERT ("Single subgoal in BadForward3. Error in I2LJape -- tell Richard."))
				)
				(ALERT	("There are no unproved conclusions associated with the antecedent %t.", sel)
							("OK", SKIP) ("Huh?",  ExplainDeadHyp stepname sel)
				)

/* ******************** the Forward menu ******************** */

TACTIC "� elim forward" IS
	WHEN	(LETHYP2 _P (_P�_Q) 
					(Noarg (CUTIN "� elim" (WITHHYPSEL (hyp _P)) (WITHHYPSEL (hyp (_P�_Q)))) "� elim")
				)
				(LETHYP2 _R (_P�_Q)
					("� elim forward fail"
						(" You selected %t, which is of the form A�B, but your other selection %t doesn't match %t.", _P�_Q, _R, _P)
					)
				)
				(LETHYP2 _P _Q
					("� elim forward fail" (" Neither of your selections (%t and %t) is of the form A�B.", _P, _Q))
				)
				(LETHYP (_P�_Q) 
					(WHEN (LETGOAL _R (Noarg (CUTIN "� elim" fstep (WITHHYPSEL hyp)) "� elim"))
								("� elim forward fail" (" You only selected %t.", _P�_Q))
					)
				)
				(LETLHS (_P�_Q)
					(WHEN (LETGOAL _R (Noarg (ForwardCut 1 "� elim") "� elim"))
								("� elim forward fail" (" You didn't select anything."))
					)
				)
				(LETHYP _P
					("� elim forward fail" (" You selected %t, which isn't of the form A�B.", _P))
				)
				(LETHYPS _P
					("� elim forward fail" (" You selected too many antecedents � %l.", (_P, ", ", " and ")))
				)
				("� elim forward fail" (" You didn't select anything."))
				
TACTIC "� elim forward fail" (extra) IS
		Fail	("To make a forward step with � elim you must select something of the form A�B, \
				\and something which matches A (or a target conclusion).%s", extra)

MENU Forward IS
	ENTRY	"� elim"									IS "� elim forward"
	ENTRY	"� elim (preserving left)"			IS Forward (QUOTE (_P�_Q)) (ForwardCut 0 (Noarg (LAYOUT "� elim" (0) "� elim(L)") "� elim"))  "� elim" "� intro" "A�B"
	ENTRY	"� elim (preserving right)"			IS Forward (QUOTE (_P�_Q)) (ForwardCut 0 (Noarg (LAYOUT "� elim" (0) "� elim(R)") "� elim")) "� elim" "� intro" "A�B"
	ENTRY	"� elim (makes assumptions)"	IS Forward (QUOTE (_P�_Q)) (Noarg ("targeted forward" (ForwardUncut 0 "� elim") "� elim") "� elim") "� elim" "� intro" "A�B"
	ENTRY	"� elim (needs variable)"				IS "� elim forward"
	ENTRY	"� elim (assumption & variable)"	IS Forward (QUOTE (�_x._P)) (Noarg ("targeted forward" (ForwardUncut 0 "� elim") "� elim") "� elim") "� elim" "� intro" "�x.A"
	ENTRY	"� elim (constructive)"				IS Forward (QUOTE _P) (Noarg "� elim (constructive)" "� elim (constructive)") "� elim (constructive)" "� intro" �

	SEPARATOR
	ENTRY	"� intro"			IS "� intro forward"

	ENTRY	"� intro (invents right)"		IS "� introforward" "� intro(L)"
	ENTRY	"� intro (invents left)"			IS "� introforward" "� intro(R)"
	
	ENTRY "� intro" IS "� intro forward"

	/* removed -- see comment on the tactic below
	ENTRY	"� intro (needs variable)"		IS "� intro forward"
	*/

	SEPARATOR
	ENTRY	hyp IS Noarg hyptac hyp
END

TACTIC "� intro forward" IS
	WHEN	(LETHYP2 _P (�_P) 
					(Noarg (CUTIN "� intro" (WITHHYPSEL (hyp _P)) (WITHHYPSEL (hyp (�_P)))) "� intro")
				)
				(LETHYP2 _P _Q
					(ALERT	("To make a forward step with � intro, it's necessary to select two antecedent formul� -- one to match \
								\A, the other to match �A. \
								\You selected %t and %t.", _P, _Q)
								("OK", STOP) ("Huh?", SEQ ExplainClicks STOP )
					)
				)
				(LETHYP _P 
					(ALERT	("To make a forward step with � intro, it's necessary to select two antecedent formul� -- one to match \
								\A, the other to match �A. \
								\You only selected %t.", _P)
								("OK", STOP) ("Huh?", SEQ ExplainClicks STOP )
					)
				) 
				(LETHYPS _Ps 
					(ALERT	("To make a forward step with � intro, it's necessary to select only two antecedent formul� to combine. \
								\You selected %l.", (_Ps, ", ", " and "))
								("OK", STOP) ("Huh?", SEQ ExplainClicks STOP )
					)
				) 
				(LETGOAL �
					(ALERT	("To make a forward step with � intro, it's necessary to select two antecedent formul� -- one to match \
								\A, the other to match �A. \
								\You didn�t select any at all.\
								\\n\nHowever, the current conclusion fits � intro going backwards. Did you perhaps mean to \
								\make a backward step?", _P�_Q)
								("OK", STOP) ("Huh?", SEQ ExplainClicks STOP )
					)
				)
				(ALERT	("To make a forward step with � intro, it's necessary to select two antecedent formul� -- one to match \
								\A, the other to match �A. \
							\You didn�t select any at all.")
							("OK", STOP) ("Huh?", SEQ ExplainClicks STOP )
				)

	
TACTIC "targeted forward" (action, stepname) IS
	WHEN	(LETHYP _Ph ("targeted forward 2" action stepname _Ph))
				(LETLHS _Ph ("targeted forward 2" action stepname _Ph))
				(Fail ("Error in I2LJape (� elim forward falls through). Tell Richard."))
				
TACTIC "targeted forward 2"(action, stepname, hyp) IS
	(WHEN	(LETCONC _P action) 
				(LETOPENSUBGOAL G _Pg ("targeted forward single" action stepname G hyp _Pg))
				(LETOPENSUBGOALS _Ps
					(ALERT	("The %s step needs a �target� conclusion to work towards. \
								\Please click on one of the unproved conclusions � %l � and try the \
								\%s step again.", stepname, (_Ps, ", ", " or "), stepname)
								("OK", STOP) ("Huh?", Explainunprovedconclusionwords)
					)
				)
				(BadForward3 hyp stepname) 
	)
MACRO "targeted forward single"(action, stepname, path, selhyp, ogoal) IS
	LETGOALPATH G1
		(WHEN	(LETMATCH path G1 action) /* just do it, it's the next line */
					(ALERT	("The %s step needs a �target� conclusion to work towards. \
								\There's only one unproved conclusion (%t) which is relevant to the antecedent %t \
								\which you selected.\
								\\nWould you like to proceed, using %t as the target?\
								\\n(You can avoid this message in the future if you always select the target conclusion \
								\before making the %s step.)", stepname, ogoal, selhyp, ogoal, stepname)
								("OK", SEQ (GOALPATH path) action) ("Huh?", SEQ Explainantecedentandconclusionwords STOP)
								("Cancel", STOP)
					)
		)

/* ******************** explanations ******************** */

TACTIC ExplainHypMulti (stepname, Ph) IS
	WHEN	(LETOPENSUBGOALS _Pandgs
					(ALERT	("The lines of dots in a proof-in-progress mark places where there is still work to be done. \
								\The formula just below a line of dots is an unproved conclusion (notice that those formulae \
								\don't have reasons next to them). Your job is to show that each unproved conclusion follows \
								\from the line(s) above it. \
								\\n\nYou selected the antecedent %t, and the unproved conclusions which can use that \
								\antecedent are %l. (Conclusions which can't make use of the antecedent are 'greyed out'.)\
								\\n\nIf you select one of those unproved conclusions AS WELL AS selecting %t, then Jape can make a \
								\forward step and put the new formulae that it generates just before the conclusion you selected.", 
								Ph, (_Pandgs, ", ", " and "), Ph)
								("OK", STOP) ("Huh?", SEQ Explainantecedentandconclusionwords STOP)
					)
				)
				
TACTIC ExplainDeadHyp (stepname, Ph) IS
	ALERT	("When you select an antecedent, Jape shows the unproved conclusions that can make use of it \
				\in black, and any other conclusions � proved or unproved � in grey. You can see that there are no \
				\non-grey unproved conclusions in the proof, after you selected %t. \
				\\n\n(If there are any unproved conclusions in the proof, they are greyed-out either because \
				\they are above %t, or because they are inside a box that %t is outside.)",
				Ph, Ph, Ph)
				("OK", STOP) ("Huh?", SEQ Explainunprovedconclusionwords STOP)

TACTIC ExplainClicks IS
	Fail	("Click on a formula to select it.\n\n\
	         \The red selection marking shows you how you can work with the selected formula.\n\
	         \You can make a forward step from a selection open at the bottom (a downward selection).\n\
	         \You can make a backward step from a selection open at the top (an upward selection).\n\n\
	         \If you want to control where I2L Jape writes the result of a forward step, make both a downward and \
	         \an upward selection � the result will be written just before the upward selection, above the line of three dots.")

TACTIC Explainantecedentandconclusionwords IS
	Fail	("When you select an antecedent, you get a downward-pointing selection (a box round the \
			\formula, open at the bottom). You work forward from an antecedent selection.\
			\\n\nUnproved conclusion formulae are written with three dots above them. \
			\When you select an unproved conclusion, you get \
			\an upward-pointing selection (a box round the formula, open at the top). You work \
			\backwards from a conclusion selection, or it can be a target for a forward step.\
			\\n\nSome formulae can be used as antecedent or as unproved conclusion. In those cases \
			\the selection box has a dotted horizontal line. Click in the bottom half of the formula to make an \
			\antecedent selection, in the top half for a conclusion selection. or antecedent.\
			\\n\nAny formula can be used as an antecedent if there are relevant unproved conclusions below it \
			\in the proof.")

TACTIC Explainunprovedconclusionwords IS
	Fail	"Lines of dots mark places where there is still work to be done. \
			\The formula just below a line of dots is an unproved conclusion. \
			\Your job is to show that each unproved conclusion follows \
			\from the line(s) above it.\
			\\nWhen there are no unproved conclusions left, the proof is finished."

TACTIC ExplainDeadConc (stepname, Pc, stuff) IS
	Fail	("In making a proof, you normally select unproved conclusions � formulae just below a line of dots, \
			\with no proof-step reason written next to them. You are allowed to select proved conclusions, however, \
			\because sometimes you want to backtrack or prune the proof.  \
			\\n\nThe conclusion %t which you selected is already proved � it has a proof-step reason written next to \
			\it � so you can't make a forward step towards it, or a backward step from it.%s", Pc, stuff)
				
TACTIC ExplainMulti (stepname, stuff) IS 
	Fail	("The lines of dots in a proof-in-progress mark places where there is still work to be done. \
			\The formula just below a line of dots is an unproved conclusion (notice that those formulae \
			\don't have reasons next to them). \
			\In this proof there's more than one line of dots, which means more than one \
			\unproved conclusion.\
			\Your job is to show that each unproved conclusion follows from the line(s) above it. \
			\\n\nJape puts the results of a forward step just before a line of dots; it puts the results of a \
			\backward step just after a line of dots. If there is more than one line of dots in the proof, \
			\you must tell it where to do its work.\
			\\n\nSo if you want to make a forward step in this proof, you must select (click on) \
			\an unproved conclusion AS WELL AS an antecedent. If you want to make a backward step,\
			\ you only need to select an unproved conclusion.%s", stuff
			)

TACTIC Explainvariables IS
ALERT	"Variables are introduced into a proof by � intro and/or � elim. They appear at the head of a box \
			\as a special pseudo-assumption actual c (this is Jape's version of scope-boxing; it uses variable \
			\names c, c1, and so on as appropriate). \
			\\n\nYou have to select one of these pseudo-assumptions each time you make a � elim or � intro step.\
			\\n\nThe box enclosing actual ... is the scope of the variable. If there are unknowns in your proof, \
			\Jape will protect the scope box \
			\by putting a proviso such as c NOTIN _B in the Provisos pane .  If you try to \
			\break the scope using hyp or Unify then Jape will stop you, quoting the proviso."
			
TACTIC Explainprovisos IS
	ALERT "The proviso c NOTIN _B (for example) appears when the unknown _B occurs both inside \
				\AND outside variable c's scope box. It means that nothing unified with _B can contain \
				\the variable c, because that would produce an occurrence of c outside its scope box."

TACTIC CrashHypDeadConc IS
	Fail "I2L Jape error (hyp and dead conc selected). Tell Richard"
	
TACTIC CrashNoHypNoConcs IS
	Fail "I2L Jape error (no sel no concs). Tell Richard."

/* ******************** we don't like some of the automatic alerts ******************** */

PATCHALERT "double-click is not defined" 
	"Double-clicking a formula doesn't mean anything in I2L Jape: you have to select (single-click) and \
	\then choose a step from the Backward or Forward menu."
	("OK")
	
PATCHALERT "You double-clicked on a used antecedent or a proved conclusion"
	"Double-clicking a formula doesn't mean anything in I2L Jape: you have to select (single-click) and \
	\then choose a step from the Backward or Forward menu."
	("OK")

PATCHALERT "To make an � intro step forward"
	("OK") ("Huh?", HowToTextSelect)

PATCHALERT "The � intro step can accept a single argument" 
	("OK") ("Huh?", HowToTextSelect)
	
/* ******************** and we do our own (careful) unification ******************** */

MENU Edit
	ENTRY Unify IS I2Lunify
END

TACTIC I2Lunify IS
	WHEN	(LETMULTIARG _Ps
					(ALT UNIFYARGS
				 			(BADUNIFY X Y (ALERT ("%t and %t don't unify, because the formula structures don't match.", X, Y) ("OK", STOP)))
				 			(BADMATCH X Y (ALERT ("%t and %t don't unify, because to do so would change the proof (you shouldn't see this message).", X, Y) ("OK", STOP)))
				 			(BADPROVISO X Y P 
				 				(ALERT ("%t and %t don't unify, because to do so would smuggle a variable out of its scope \
				 							\(see the proviso %s in the proviso pane).", X, Y, P)
				 							("OK", STOP)
				 							("Huh?", SEQ Explainprovisos STOP)
				 				) 
				 			)
				 	)
				 )
				 (SEQ (ALERT "To use Unify, you must text-select more than one formula.") STOP)

/* this hack to get at HowToTextSelect from within a tactic -- I must do this properly asap */
PATCHALERT "To use Unify, "
	("OK") ("Huh?", HowToTextSelect)
