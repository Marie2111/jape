/* $Id$ */
/*
	Theorems on which to try your hand
*/

CONJECTUREPANEL Conjectures
	THEOREM INFER C � �x.x : T�T
	THEOREM INFER C � �f.�g.�x.f(g x) : (T1�T2) � (T3�T1) � T3 � T2
	THEOREM INFER C � �f.�g.�x.f(g x) : _T
	THEOREM INFER C � �f.�g.�x.f(g x) : _T
	THEOREM INFER C � �x.�x.x : T1�T2�T2
	THEOREM INFER C � �x.�x.x : _T
	THEOREM INFER C � �x.�y.�y.x : T1�T2�T3�T1
	THEOREM INFER C � �x.�y.�y.x : _T
	DERIVED RULE FROM  C � x:T INFER C � letrec f = �x.x in f x end : T
	DERIVED RULE FROM  C � x:Tx AND  C � y:Ty  INFER C � letrec f = �x.x in (f x, f y) end : Tx�Ty
	DERIVED RULE FROM  C � x:Tx AND  C � y:Ty  INFER C � letrec f = �x.x in (f x, f y) end  : _T
	THEOREM INFER C � let f = �x.�y.(x,y) in (f 3 4, f (3,4) 1) end : _T
	THEOREM INFER C � let f = �x.let g = �y.(x,y) in g end in f end : _T
	THEOREM INFER C � letrec f = �x.f x in f end: _T
	THEOREM INFER C � let f = let g = �x.x in g end in f f end :_T
	THEOREM INFER C � letrec f = let g = �x.f x in g end in f end : _T
	/* the next one won't typecheck ... */
	THEOREM INFER C � letrec f = let g = �x.x f in g end in f end : _T
	THEOREM INFER C � letrec map = �f.�xs.if xs==nil then nil else f (hd xs)�map f (tl xs) fi in map end : _T
	THEOREM INFER C � letrec map = �f.�xs.if xs==nil then nil else f (hd xs)�map f (tl xs) fi , 
	                       f = �x.x+x
	              in map f (0�1�2�nil)
	              end : _T
	DERIVED RULE FROM C � x:Tx INFER C � let f = �x.�y.x in f 3 end : _T
	DERIVED RULE FROM C � E:TE INFER C � let f = �x.�y.E in f 3 end : _T
	DERIVED RULE  FROM C � e:Te INFER C � let x = (e,e) in x end : _T
	DERIVED RULE FROM C � f� #num�num�num INFER C � let g = �x.f(x,3) in g 4 end : _T
	DERIVED RULE FROM C � finc� #num�num AND C � fdec� #num�num 
		INFER C � letrec fadd = �x.�y.if x==0 then y else fadd (fdec x) (finc y) fi in fadd end : _T
END


