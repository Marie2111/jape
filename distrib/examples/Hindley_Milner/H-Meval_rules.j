/* $Id$ */

FONTS "Konstanz"

CLASS VARIABLE x, y, z, e, f, g, map
CLASS FORMULA E, F, G, C
CLASS CONSTANT c
CONSTANT hd, tl, nil
CLASS NUMBER n
CLASS STRING s
CONSTANT true, false

LEFTFIX � .
BIND x  SCOPE E IN � x . E

CLASS VARIABLE t
CLASS FORMULA S, T /* we use T for types, S for type schemes in the rules which follow */
CONSTANT bool, string, num

LEFTFIX    � .
BIND t SCOPE T IN � t . T
BIND t1,t2 SCOPE T IN � (t1,t2) . T
BIND t1,t2,t3 SCOPE T IN � (t1,t2,t3) . T
BIND t1,t2,t3,t4 SCOPE T IN � (t1,t2,t3,t4) . T

PREFIX ^ /* how I wish we had control over the priority of prefix operators ... */

INFIX   30 30 and
INFIX	    40  40   �
INFIX    50  50   : , �, �, �, �
INFIX   101 100 �
INFIX   102 102 �
/* operators for programs */
INFIXC  103 103 =
INFIXC  115 115 +, -
INFIXC   114 113 �

OUTFIX { }
OUTFIX  letrec in end
OUTFIX  let     in end
OUTFIX  if then else fi

BIND x  			SCOPE F	IN let x = E in F end
BIND x1, x2  		SCOPE F	IN let x1=E1 and x2=E2 in F end
BIND x1,x2,x3		SCOPE F	IN let x1=E1 and x2=E2 and x3=E3 in F end
BIND x1,x2,x3,x4	SCOPE F	IN let x1=E1 and x2=E2 and x3=E3 and x4=E4 in F end

BIND x			SCOPE E, F			IN letrec x = E in F end
BIND x1,x2		SCOPE E1, E2, F		IN letrec x1=E1 and x2=E2 in F end
BIND x1,x2,x3		SCOPE E1, E2, E3, F		IN letrec x1=E1 and x2=E2 and x3=E3 in F end
BIND x1,x2,x3,x4	SCOPE E1, E2, E3, E4, F	IN letrec x1=E1 and x2=E2 and x3=E3 and x4=E4 in F end

SEQUENT IS FORMULA � FORMULA

RULES letrules ARE
	FROM C � E : T1 
	AND C � ^T1�S1 
	AND C�x�S1 � F:T	
	INFER C � let x=E in F end : T
AND	FROM C � (E1,E2) : T1�T2 
	AND C � ^T1�^T2�S1�S2 
	AND C�x1�S1�x2�S2 � F:T
	INFER C � let x1=E1 and x2=E2 in F end : T
AND	FROM C � (E1,(E2,E3)) : T1�(T2�T3) 
	AND C � ^T1�^T2�^T3�S1�S2�S3 
	AND C�x1�S1�x2�S2�x3�S3 � F:T
	INFER C � let x1=E1 and x2=E2 and x3=E3 in F end : T
AND	FROM C � ((E1,E2),(E3,E4)) : (T1�T2)�(T3�T4) 
	AND C � ^T1�^T2�^T3�^T4�S1�S2�S3�S4
	AND C�x1�S1�x2�S2�x3�S3�x4�S4 � F:T
	INFER C � let x1=E1 and x2=E2 and x3=E3 and x4=E4 in F end : T
END

RULES letrecrules ARE
	FROM C�x�^T1 � E:T1 
	AND C � ^T1�S1 
	AND C�x�S1 � F:T	
	INFER C � letrec x=E in F end : T
AND	FROM C�x1�^T1�x2�^T2 � (E1,E2) : T1�T2 
	AND C � ^T1�^T2�S1�S2 
	AND C�x1�S1�x2�S2 � F:T	
	INFER C � letrec x1=E1 and x2=E2 in F end : T
AND	FROM C�x1�^T1�x2�^T2�x3�^T3 � (E1,(E2,E3)) : T1�(T2�T3) 
	AND C � ^T1�^T2�^T3�S1�S2�S3 
	AND C�x1�S1�x2�S2�x3�S3 � F:T
	INFER C � letrec x1=E1 and x2=E2 and x3=E3 in F end : T
AND	FROM C�x1�^T1�x2�^T2�x3�^T3�x4�^T4 � ((E1,E2),(E3,E4)) : (T1�T2)�(T3�T4) 
	AND C � ^T1�^T2�^T3�^T4�S1�S2�S3�S4 
	AND C�x1�S1�x2�S2�x3�S3�x4�S4 � F:T
	INFER C � letrec x1=E1 and x2=E2 and x3=E3 and x4=E4 in F end : T
END

RULES constants ARE
	C � hd�(�t.{t}�t)
AND	C � tl�(�t.{t}�{t})
AND	C � (�)�(�t.t�{t}�{t})
AND	C � nil�(�t.{t})
AND	C � (+)�^(num�num�num)
AND	C � (-)�^(num�num�num)
AND C � (=)�(�t.t�t�bool)
END

RULE "C�x�S � x�S" IS INFER C�x�S � x�S
RULE "C�y�... �  x�S" WHERE x NOTIN E IS FROM C � x�S INFER C�E�S1 � x�S 
TACTIC "C � x�S" IS ALT "C�x�S � x�S" (SEQ "C�y�... �  x�S" "C � x�S")

RULE "C�c�S � c�S" IS INFER C�c�S � c�S
RULE "C�y�... �  c�S" WHERE c NOTIN E IS FROM C � c�S INFER C�E�S1 � c�S 
				/* NOTIN still needed in case E is unknown */
TACTIC "C � c�S" IS ALT "C�c�S � c�S" (SEQ "C�y�... �  c�S" "C � c�S")

RULE "C � x:T" IS FROM C�x�S AND C�S�T INFER C�x:T
RULE "C � c:T" IS FROM C�c�S AND C�S�T INFER C�c:T

RULES "S�T" ARE
	INFER C � ^T � T
AND	INFER C � (�t.T) � T[t\T1]
AND	INFER C � (�(t1,t2).T) � T[t1,t2\T1,T2]
AND	INFER C � (�(t1,t2,t3).T) � T[t1,t2,t3\T1,T2,T3]
AND	INFER C � (�(t1,t2,t3,t4).T) � T[t1,t2,t3,t4\T1,T2,T3,T4]
END

MENU Rules IS	
	RULE "F G : T"		FROM C � F: T1�T2 AND C � G : T1 	INFER  C � F G : T2
	RULE "(�x.E) : T1�T2"
					FROM C�x�^T1 � E:T2 			INFER C � (�x.E) : T1�T2
	RULE "(E,F) : T1�T2"	
					FROM C � E: T1 AND C � F: T2		INFER C � (E,F) : T1�T2
	RULE "if E then ET else EF fi : T"
		FROM C � E : bool AND C � ET : T AND C � EF : T		INFER C � if E then ET else EF fi : T
	ENTRY "let ... : T" IS letrules
	ENTRY "letrec ... : T" IS letrecrules
	
	TACTIC "x:T" IS
		LAYOUT "C(x)�S; S�T" () 
			(ALT	(SEQ "C � x:T" "C � x�S") 
				(SEQ "C � c:T" (ALT constants "C � c�S"))
				(WHEN
					(LETGOAL (_E:_T)
						(JAPE(fail(x:T can only be applied to either variables or constants: you chose _E)))
					)
					(LETGOAL _E (JAPE(fail(conclusion _E is not a ' formula:type ' judgement)))
					)
				)
			) 
			"S�T"
	
	SEPARATOR
	
	RULE "n:num"				INFER C � n:num
	RULE "s:string"				INFER C � s:string
	RULE "true:bool"			INFER C � true:bool
	RULE "false:bool"			INFER C � false:bool
	
	SEPARATOR
	
	ENTRY generalise
	
	SEPARATOR
	
	ENTRY Auto
	ENTRY AutoStep
	
END
    
RULE "^T�S" IS			FROM C � T � () � Ts AND C � (T,Ts) � S		INFER C � ^T � S
RULE "T1�T2�S1�S2" IS	FROM C � T1�S1 AND C � T2�S2		INFER C � T1�T2�S1�S2

RULE "t�..." (OBJECT t) WHERE t NOTIN C AND t NOTIN Ts IS			INFER C � t � Ts � (t,Ts)
RULE "T1�T2�..."		FROM C � T1� Tsin � Tsmid AND C � T2 � Tsmid � Tsout	
														INFER C � T1�T2 � Tsin � Tsout
RULE "T1�T2�..."		FROM C � C � T1� Tsin � Tsmid AND C � T2 � Tsmid � Tsout	
														INFER C � T1� T2 � Tsin � Tsout
RULE "T�..."												INFER C � T � Ts � Ts

RULES"�" ARE
	INFER C � (T,()) � ^T
AND	INFER C � (T,(t,())) � (�t.T)
AND INFER C � (T,(t2,(t1,()))) � (�(t1,t2).T)
AND INFER C � (T,(t3,(t2,(t1,())))) � (�(t1,t2,t3).T)
AND INFER C � (T,(t4,(t3,(t2,(t1,()))))) � (�(t1,t2,t3,t4).T)
END

TACTIC geninduct IS ALT "t�..." (SEQ (MATCH (ALT "T1�T2�..." "T1�T2�...")) geninduct geninduct) "T�..."

 TACTIC generalise IS
 	 LAYOUT "generalise %s" ()  
		(ALT	(SEQ "^T�S" geninduct "�")
			(SEQ "T1�T2�S1�S2" generalise generalise)
		)

TACTIC Auto IS
	WHEN	(LETGOAL (_x:_T) "x:T")
			(LETGOAL (_c:_T) 
				(ALT "x:T" "n:num" "s:string" "true:bool" "false:bool"
					(JAPE (fail (_c isn't a constant from the context, or one of the fixed constants))) 
				)
			)
			(LETGOAL (_F _G:_T) "F G : T" Auto Auto)
			(LETGOAL ((_E,_F):_T) "(E,F) : T1�T2" Auto Auto)
			(LETGOAL ((�_x._E):_T) "(�x.E) : T1�T2" Auto)
			(LETGOAL (if _E then _ET else _EF fi:_T) "if E then ET else EF fi : T" Auto Auto Auto)
			(LETGOAL (let _x=_E in _F end:_T) letrules Auto generalise Auto)
			(LETGOAL (let _x1=_E1 and _x2=_E2 in _F end:_T) letrules Auto generalise Auto)
			(LETGOAL (let _x1=_E1 and _x2=_E2 and _x3=E3 in _F end:_T) letrules Auto generalise Auto)
			(LETGOAL (let _x1=_E1 and _x2=_E2 and _x3=E3 and _x4=_E4 in _F end:_T) letrules Auto generalise Auto)
			(LETGOAL (letrec _x=_E in _F end:_T) letrecrules Auto generalise Auto)
			(LETGOAL (letrec _x1=_E1 and _x2=_E2 in _F end:_T) letrecrules Auto generalise Auto)
			(LETGOAL (letrec _x1=_E1 and _x2=_E2 and _x3=E3 in _F end:_T) letrecrules Auto generalise Auto)
			(LETGOAL (letrec _x1=_E1 and _x2=_E2 and _x3=E3 and _x4=_E4 in _F end:_T) letrecrules Auto generalise Auto)
			(LETGOAL (_E:_T) (JAPE (fail (_E is not a recognisable program formula (Auto)))))
			(LETGOAL _E (JAPE (fail (_E is not a recognisable judgement (Auto)))))
			
TACTIC AutoStep IS
	WHEN	(LETGOAL (_x:_T) "x:T")
			(LETGOAL (_c:_T) 
				(ALT "x:T" "n:num" "s:string" "true:bool" "false:bool"
					(JAPE (fail (_c isn't a constant from the context, or one of the fixed constants))) 
				)
			)
			(LETGOAL (_F _G:_T) "F G : T")
			(LETGOAL ((_E,_F):_T) "(E,F) : T1�T2")
			(LETGOAL ((�_x._E):_T) "(�x.E) : T1�T2")
			(LETGOAL (if _E then _ET else _EF fi:_T) "if E then ET else EF fi : T")
			(LETGOAL (let _x=_E in _F end:_T) letrules)
			(LETGOAL (let _x1=_E1 and _x2=_E2 in _F end:_T) letrules)
			(LETGOAL (let _x1=_E1 and _x2=_E2 and _x3=E3 in _F end:_T) letrules)
			(LETGOAL (let _x1=_E1 and _x2=_E2 and _x3=E3 and _x4=_E4 in _F end:_T) letrules)
			(LETGOAL (letrec _x=_E in _F end:_T) letrecrules)
			(LETGOAL (letrec _x1=_E1 and _x2=_E2 in _F end:_T) letrecrules)
			(LETGOAL (letrec _x1=_E1 and _x2=_E2 and _x3=E3 in _F end:_T) letrecrules)
			(LETGOAL (letrec _x1=_E1 and _x2=_E2 and _x3=E3 and _x4=_E4 in _F end:_T) letrecrules)
			(LETGOAL (_E:_T) (JAPE (fail (_E is not a recognisable program formula (AutoStep)))))
			(LETGOAL _E (JAPE (fail (_E is not a recognisable judgement (AutoStep)))))
			
AUTOUNIFY "n:num", "s:string", "true:bool", "false:bool"
