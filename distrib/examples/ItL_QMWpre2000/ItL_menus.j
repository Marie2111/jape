/* $Id$ */

TACTIC ForwardCut (n,Rule)
  SEQ cut (WITHARGSEL Rule) (JAPE (SUBGOAL n)) (WITHHYPSEL hyp)

TACTIC ForwardUncut (n,Rule)
  SEQ (WITHARGSEL Rule) (JAPE (SUBGOAL n)) (WITHHYPSEL hyp)

TACTIC ForwardOrBackward (Forward, n, Rule) IS 
	WHEN	(LETHYP 
				_P 
                          	(ALT	(Forward n Rule)
					(WHEN	(LETARGSEL _Q 
                                                              (FAIL (Rule is not applicable to assumption ' _P ' with argument ' _Q '))
							)
							(FAIL (Rule is not applicable to assumption ' _P '))
					)
                                )
			)
			(ALT	(WITHSELECTIONS Rule)
                   		(WHEN	(LETARGSEL _P
                                                	(FAIL (Rule is not applicable with argument ' _P '))
                                              	)
						(FAIL (Rule is not applicable))
				)
           		)
   
MENU Rules IS
    ENTRY "�-I"
    ENTRY "�-I"	
    ENTRY "�-I(L)"	IS ForwardOrBackward ForwardCut 0 "�-I(L)"
    ENTRY "�-I(R)"	IS ForwardOrBackward ForwardCut 0 "�-I(R)"
    ENTRY "�-I"
    ENTRY "�-I"
    ENTRY "�-I"
    SEPARATOR
    ENTRY "�-E"	IS ForwardOrBackward ForwardCut 1 "�-E" 
    ENTRY "�-E(L)"	IS ForwardOrBackward ForwardCut 0 "�-E(L)"
    ENTRY "�-E(R)" 	IS ForwardOrBackward ForwardCut 0 "�-E(R)"
    ENTRY "�-E"		IS ForwardOrBackward ForwardUncut 0 "�-E"	
    ENTRY "�-E"		IS ForwardOrBackward ForwardCut 0 "�-E"	
    ENTRY "�-E"		IS ForwardOrBackward ForwardCut 0 "�-E"	
    ENTRY "�-E"		IS ForwardOrBackward ForwardUncut 0 "�-E"
    SEPARATOR
    ENTRY hyp
END

