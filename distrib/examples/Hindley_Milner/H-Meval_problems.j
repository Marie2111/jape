/* $Id$ */
/*
	Theorems on which to try your hand
*/

CONJECTUREPANEL Conjectures
	THEOREMS "Hindley_Milner" ARE
		C � �x.x : T�T
	AND	C � �f.�g.�x.f(g x) : (T1�T2) � (T3�T1) � T3 � T2
	AND	C � �f.�g.�x.f(g x) : _T
	AND	C � �f.�g.�x.f(g x) : _T
	AND	C � �x.�x.x : T1�T2�T2
	AND	C � �x.�x.x : _T
	AND	C � �x.�y.�y.x : T1�T2�T3�T1
	AND	C � �x.�y.�y.x : _T
	/* these really should be derived rules - e.g. FROM C � x:T INFER ... */
	AND	C,x�#T � letrec f = �x.x in f x end : T
	AND	C,x�#Tx,y�#Ty � letrec f = �x.x in (f x, f y) end : Tx�Ty
	AND	C,x�#Tx,y�#Ty � let f =  �x.x in (f x, f y) end : _T
	AND	C � let f = �x.�y.(x,y) in (f 3 4, f (3,4) 1) end : _T
	AND	C � let f = �x.let g = �y.(x,y) in g end in f end : _T
	AND	C � letrec f = �x.f x in f end: _T
	AND	C � let f = let g = �x.x in g end in f f end :_T
	AND	C � letrec f = let g = �x.f x in g end in f end : _T
	/* the next one won't typecheck ... */
	AND	C � letrec f = let g = �x.x f in g end in f end : _T
	AND	C � letrec map = �f.�xs.if xs==nil then nil else f (hd xs)�map f (tl xs) fi in map end : _T
	AND	C � letrec map = �f.�xs.if xs==nil then nil else f (hd xs)�map f (tl xs) fi , 
	                       f = �x.x+x
	              in map f (0�1�2�nil)
	              end : _T
	/* another that should be a derived rule */
	AND	C,x�#Tx � let f = �x.�y.x in f 3 end : _T
	/* Two non-theorems -- they're actually derived rules because C can't map E or e */
	AND	E � #TE � let f = �x.�y.E in f 3 end : _T
	AND	e � #Te � let x = (e,e) in x end : _T
	/* two more that should be derived rules */
	AND	C, f� #num�num�num � let g = �x.f(x,3) in g 4 end : _T
	AND	C,finc� #num�num , fdec� #num�num 
		� letrec fadd = �x.�y.if x==0 then y else fadd (fdec x) (finc y) fi in fadd end : _T
	END
END


