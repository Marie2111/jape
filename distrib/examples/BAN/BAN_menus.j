/* $Id$ */

TACTIC FAIL(x) IS JAPE (fail x)

TACTIC ForwardCut (n,Rule)
  SEQ cut (WITHARGSEL Rule) (JAPE (SUBGOAL n)) (WITHHYPSEL hyp)

TACTIC ForwardUncut (n,Rule)
  SEQ (WITHARGSEL Rule) (JAPE (SUBGOAL n)) (WITHHYPSEL hyp)

TACTIC ForwardOrBackward (Forward, n, Rule)
	WHEN	(LETHYP 
				_X 
                          	(ALT	(Forward n Rule)
					(WHEN	(LETARGSEL _Y 
                                                              (FAIL (Rule is not applicable to assumption ' _X ' with argument ' _Y ' ))
							)
							(FAIL (Rule is not applicable to assumption ' _X ' ))
					)
                                )
			)
			(LETGOAL
				_X
				(ALT	(WITHSELECTIONS Rule)
	                   		(WHEN	(LETARGSEL _Y
	                                                	(FAIL (Rule is not applicable to conclusion ' _X ' with argument ' _Y ' ))
	                                              	)
							(FAIL (Rule is not applicable to conclusion ' _X ' ))
					)
	           		)
			)
   
MENU "�"
	SEPARATOR
	ENTRY "P�X, P�Y � P�(X+Y)"
	ENTRY "P�(X+Y) � P�X"					IS ForwardOrBackward ForwardCut 0 "P�(X+Y) � P�X"
	ENTRY "P�(X+Y) � P�Y"					IS ForwardOrBackward ForwardCut 0 "P�(X+Y) � P�Y"
	ENTRY "P�Q�(X+Y) � P�Q�X"				IS ForwardOrBackward ForwardCut 0 "P�Q�(X+Y) � P�Q�X"
	ENTRY "P�Q�(X+Y) � P�Q�Y"				IS ForwardOrBackward ForwardCut 0 "P�Q�(X+Y) � P�Q�Y"
	SEPARATOR
	ENTRY "[P�#X], P�Q�X � P�Q�X"			IS ForwardOrBackward ForwardCut 1 "P�#X, P�Q�X � P�Q�X"
	ENTRY "[P�Q�X], P�Q�X � P�X"			IS ForwardOrBackward ForwardCut 1 "P�Q�X, P�Q�X � P�X"
	SEPARATOR
	ENTRY "P�#X, [P�Q�X] � P�Q�X"			IS ForwardOrBackward ForwardCut 0 "P�#X, P�Q�X � P�Q�X"
	ENTRY "P�Q�X, [P�Q�X] � P�X"			IS ForwardOrBackward ForwardCut 0 "P�Q�X, P�Q�X � P�X"
	ENTRY "P�#X, [P�Q�X] � P�Q�X"			IS ForwardOrBackward ForwardCut 0 "P�#X, P�Q�X � P�Q�X"
	ENTRY "[P�#X], P�Q�X � P�Q�X"			IS ForwardOrBackward ForwardCut 1 "P�#X, P�Q�X � P�Q�X"
END

MENU "�"
	ENTRY "[P�(Q,P)�K], P�{X}K � P�Q�X"		IS ForwardOrBackward ForwardCut 1 "P�(Q,P)�K, P�{X}K � P�Q�X"
	ENTRY "[P�Q�K], P�{X}K� � P�Q�X"		IS ForwardOrBackward ForwardCut 1 "P�Q�K, P�{X}K� � P�Q�X"
	ENTRY "[P�(P,Q)�Y], P�<X>Y � P�Q�X"		IS ForwardOrBackward ForwardCut 1 "P�(P,Q)�Y, P�<X>Y � P�Q�X"
	SEPARATOR
	ENTRY "P�(X+Y) � P�X" 					IS ForwardOrBackward ForwardCut 0 "P�(X+Y) � P�X" 
	ENTRY "P�(X+Y) � P�Y" 					IS ForwardOrBackward ForwardCut 0 "P�(X+Y) � P�Y" 
	ENTRY "P�<X>Y � P�X" 					IS ForwardOrBackward ForwardCut 0 "P�<X>Y � P�X"
	ENTRY "[P�(P,Q)�K], P�{X}K � P�X"		IS ForwardOrBackward ForwardCut 1 "P�(P,Q)�K, P�{X}K � P�X"
	ENTRY "[P�P�K], P�{X}K � P�X"			IS ForwardOrBackward ForwardCut 1 "P�P�K, P�{X}K � P�X"
	ENTRY "[P�Q� K], P�{X}K� � P�X"			IS ForwardOrBackward ForwardCut 1 "P�Q� K, P�{X}K� � P�X"
	SEPARATOR
END

MENU "�"
	ENTRY "[P�#X], P�Q�X � P�Q�X"			IS ForwardOrBackward ForwardCut 1 "P�#X, P�Q�X � P�Q�X"
	SEPARATOR
	ENTRY "P�Q�(X+Y) � P�Q�X"			IS ForwardOrBackward ForwardCut 0 "P�Q�(X+Y) � P�Q�X"
	ENTRY "P�Q�(X+Y) � P�Q�Y"			IS ForwardOrBackward ForwardCut 0 "P�Q�(X+Y) � P�Q�Y"
	SEPARATOR
	ENTRY "[P�(Q,P)�K], P�{X}K � P�Q�X"		IS ForwardOrBackward ForwardCut 1 "P�(Q,P)�K, P�{X}K � P�Q�X"
	ENTRY "[P�Q�K], P�{X}K� � P�Q�X"		IS ForwardOrBackward ForwardCut 1 "P�Q�K, P�{X}K� � P�Q�X"
	ENTRY "[P�(P,Q)�Y], P�<X>Y � P�Q�X"		IS ForwardOrBackward ForwardCut 1 "P�(P,Q)�Y, P�<X>Y � P�Q�X"
END

MENU "�"
	ENTRY "P�Q�X, [P�Q�X] � P�X"			IS ForwardOrBackward ForwardCut 0 "P�Q�X, P�Q�X � P�X"
END

MENU "�"
	ENTRY "P�(P,Q)�Y, [P�<X>Y] � P�Q�X"		IS ForwardOrBackward ForwardCut 0 "P�(P,Q)�Y, P�<X>Y � P�Q�X"
	SEPARATOR
	ENTRY "P�(R,R')�K � P�(R',R)�K"			IS ForwardOrBackward ForwardCut 0 "P�(R,R')�K � P�(R',R)�K"	
	ENTRY "P�Q�(R,R')�K � P�Q�(R',R)�K"		IS ForwardOrBackward ForwardCut 0 "P�Q�(R,R')�K � P�Q�(R',R)�K"
END

MENU "�"
	ENTRY "P�Q�K, [P�{X}K�] � P�Q�X"		IS ForwardOrBackward ForwardCut  0 "P�Q�K, P�{X}K� � P�Q�X"
	ENTRY "P�P�K, [P�{X}K] � P�X"			IS ForwardOrBackward ForwardCut 0 "P�P�K, P�{X}K � P�X"
	ENTRY "P�Q� K, [P�{X}K�] � P�X"			IS ForwardOrBackward ForwardCut 0 "P�Q� K, P�{X}K� � P�X"
END

MENU "�"
	ENTRY "P�(Q,P)�K, [P�{X}K] � P�Q�X"		IS ForwardOrBackward ForwardCut 0 "P�(Q,P)�K, P�{X}K � P�Q�X"
	ENTRY "P�(P,Q)�K, [P�{X}K] � P�X"		IS ForwardOrBackward ForwardCut 0 "P�(P,Q)�K, P�{X}K � P�X"
	SEPARATOR
	ENTRY "P�(R,R')�K � P�(R',R)�K"		IS ForwardOrBackward ForwardCut 0 "P�(R,R')�K � P�(R',R)�K"
	ENTRY "P�Q�(R,R')�K � P�Q�(R,R')�K"	IS ForwardOrBackward ForwardCut 0 "P�Q�(R,R')�K � P�Q�(R,R')�K"
END

MENU "#"
	ENTRY "P�#X, [P�Q�X] � P�Q�X"			IS ForwardOrBackward ForwardCut 0 "P�#X, P�Q�X � P�Q�X"
	SEPARATOR
	ENTRY "P�#X � P�#(X+Y)"				IS ForwardOrBackward ForwardCut 0 "P�#X � P�#(X+Y)"
	ENTRY "P�#Y � P�#(X+Y)"				IS ForwardOrBackward ForwardCut 0 "P�#Y � P�#(X+Y)"
END

MENU "+"
	ENTRY "P�(X+Y) � P�X"					IS ForwardOrBackward ForwardCut 0 "P�(X+Y) � P�X"
	ENTRY "P�(X+Y) � P�Y"					IS ForwardOrBackward ForwardCut 0 "P�(X+Y) � P�Y"
	ENTRY "P�Q�(X+Y) � P�Q�X"				IS ForwardOrBackward ForwardCut 0 "P�Q�(X+Y) � P�Q�X"
	ENTRY "P�Q�(X+Y) � P�Q�Y"				IS ForwardOrBackward ForwardCut 0 "P�Q�(X+Y) � P�Q�Y"
	ENTRY "P�(X+Y) � P�X" 					IS ForwardOrBackward ForwardCut 0 "P�(X+Y) � P�X" 
	ENTRY "P�(X+Y) � P�Y" 					IS ForwardOrBackward ForwardCut 0 "P�(X+Y) � P�Y" 
	SEPARATOR
	SEPARATOR
	ENTRY "P�X, P�Y � P�(X+Y)"
END

MENU Logic 
	ENTRY "�x.Y(x) � Y(Z)"					IS ForwardOrBackward ForwardCut 0 "�-E"
	ENTRY hyp
END

AUTOMATCH hyp
