/* $Id$ */

INFIXC	  4010 4000 :
INFIXC	  3000 3010 ++
INFIXC	  2800 2800 �
INFIXC	  2900 2900 �, �
OUTFIX	 � �

CLASS VARIABLE v
CLASS FORMULA C, H, J, P
CONSTANT none, one, IF, true, false, if, sel, pair,
	 fst,  snd, id, cat, rcat, rev, rev2, fold,
	 map,  filter, zip, swap,
	 monoid, length

RULE weaken(A) IS FROM B INFER A � B
WEAKEN weaken

RULE listinduction (B,	OBJECT x, OBJECT xs, OBJECT ys, OBJECT v)  WHERE FRESH x, xs, ys IS
	FROM  A[v\��] AND A[v\�x�] AND A[v\xs], A[v\ys] � A[v\xs++ys] 
	INFER  A[v \ B]

THEORY	Function IS
	RULES	IF
	ARE IF true X Y = X
	AND IF false X Y	= Y
	END
	RULE	if		IS	if P (F, G) X	= IF (P X) (F X) (G X)
	RULE	"�"		IS	(F � G) X		= F(G X)
	RULE	�		IS	(F�G) X		= (F X, G X)
	RULE	�		IS	(F�G)(X,Y)	= (F X, G Y)
	RULE	id		IS	id X			= X
	RULE	fst		IS	fst(X,Y)		= X
	RULE	snd		IS	snd(X,Y)		= Y
	RULE	swap		IS	swap(X,Y)		= (Y,X)
END

TACTIC "list induction tactic" IS 
	WHEN	(LETSUBSTSEL _A (WITHSUBSTSEL listinduction))
			(FAIL(Please select a sub-formula on which to perform induction))

RULE	BoolCases(B,OBJECT x) IS FROM A[x\true] AND A[x\false] INFER A[x\B]

RULE monoid(F, Z, OBJECT A, OBJECT B, OBJECT C) IS	
	FROM F A (F B C) = F (F A B) C AND F A Z = A AND F Z B = B 
	INFER monoid F Z
	
THEORY	List IS
	RULES length 
	ARE	length �� = 0
	AND	length �X� = 1
	AND	length (Xs++Ys) = length Xs+length Ys
	END
	
	RULE	none IS none X	= ��
	RULE	one IS	one X	= �X�

	RULE	cat IS	cat = fold (++) ��

	RULES	rev
	ARE rev ��		= ��
	AND rev �X�		= �X �
	AND rev (Xs++Ys)	= rev Ys ++ rev Xs
	END

	RULES	++
	ARE ��++Ys		= Ys
	AND Xs++��		= Xs
	AND (Xs++Ys)++ZS	= Xs++(Ys++ZS)
	END

	RULES	map
	ARE map F ��			= ��
		AND map F �X�		= �F X�
	AND map F (Xs++Ys)	= map F Xs ++ map F Ys
	END

	RULE filter IS filter P = cat � map (if P (one, none))

	RULES zip
	ARE zip(��, ��)			= ��
	AND zip(�X�, �Y�)			= �(X,Y)�
	AND	 FROM length Xs = length Ys 
		INFER zip(Xs++Xs', Ys++Ys') = zip (Xs,Ys)++zip(Xs',Ys')
	END

	RULES fold 
	ARE fold F Z ��		= Z
	AND	 fold F Z �X�	= X
	AND	 FROM monoid F Z
		INFER fold F Z (Xs++Ys) = F (fold F Z Xs) (fold F Z Ys)
	END

	RULE rev2 IS rev2 = fold rcat �� � map one
	
	RULE rcat IS rcat Xs Ys = Ys ++ Xs
	
	RULE ":" IS X:Xs = �X� ++ Xs
END

CONSTANT ref, ins, del, move, L, R
THEORY	Reflect IS
	RULE	ref		IS	ref					= (rev�rev) � swap
	RULE	ins		IS	ins X (Xs,Ys)			= (Xs ++ �X�, Ys)
	RULE	del		IS	del	 (Xs ++ �X�, Ys)		= (Xs, Ys)
	RULE	move	IS	move (Xs ++ �X�, Ys)	= (Xs, �X� ++ Ys)
	RULE	L		IS	L F					= ref � F � ref
	RULE	R		IS	R F					= F
END





