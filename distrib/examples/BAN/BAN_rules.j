/* $Id$ */

RULE "P�(Q,P)�K, P�{X}K � P�Q�X" IS FROM P�(Q,P)�K AND P�{X}K INFER P�Q�X
RULE "P�Q�K, P�{X}K� � P�Q�X" IS FROM P�Q�K AND P�{X}K� INFER P�Q�X
RULE "P�(P,Q)�Y, P�<X>Y � P�Q�X" IS FROM P�(P,Q)�Y AND P�<X>Y INFER P�Q�X
RULE "P�#X, P�Q�X � P�Q�X" IS FROM P�#X AND P�Q�X INFER P�Q�X
RULE "P�Q�X, P�Q�X � P�X" IS FROM P�Q�X AND P�Q�X INFER P�X
RULE "P�X, P�Y � P�(X+Y)" IS FROM P�X AND P�Y INFER P�(X+Y)
RULE "P�(X+Y) � P�X" IS FROM P�(X+Y) INFER P�X
RULE "P�(X+Y) � P�Y" IS FROM P�(X+Y) INFER P�Y
RULE "P�Q�(X+Y) � P�Q�X" IS FROM P�Q�(X+Y) INFER P�Q�X
RULE "P�Q�(X+Y) � P�Q�Y" IS FROM P�Q�(X+Y) INFER P�Q�Y
RULE "P�Q�(X+Y) � P�Q�X" IS FROM P�Q�(X+Y) INFER P�Q�X
RULE "P�Q�(X+Y) � P�Q�Y" IS FROM P�Q�(X+Y) INFER P�Q�Y
RULE "P�(X+Y) � P�X" IS FROM P�(X+Y) INFER P�X
RULE "P�(X+Y) � P�Y" IS FROM P�(X+Y) INFER P�Y
RULE "P�<X>Y � P�X" IS FROM P�<X>Y INFER P�X
RULE "P�(P,Q)�K, P�{X}K � P�X" IS FROM P�(P,Q)�K AND P�{X}K INFER P�X
RULE "P�P�K, P�{X}K � P�X" IS FROM P�P�K AND P�{X}K INFER P�X
RULE "P�Q� K, P�{X}K� � P�X" IS FROM P�Q� K AND P�{X}K� INFER P�X
RULE "P�#X � P�#(X+Y)" IS FROM P�#X INFER P�#(X+Y)
RULE "P�#Y � P�#(X+Y)" IS FROM P�#Y INFER P�#(X+Y)
RULE "P�(R,R')�K � P�(R',R)�K" IS FROM P�(R,R')�K INFER P�(R',R)�K
RULE "P�Q�(R,R')�K � P�Q�(R,R')�K" IS FROM P�Q�(R,R')�K INFER P�Q�(R',R)�K
RULE "P�(R,R')�K � P�(R',R)�K" IS FROM P�(R,R')�K INFER P�(R',R)�K
RULE "P�Q�(R,R')�K � P�Q�(R',R)�K" IS FROM P�Q�(R,R')�K INFER P�Q�(R',R)�K	

/* I hope we can use hyp, else a sequent presentation is impossible; I' m sure that we can use cut */
RULE hyp IS INFER X � X
RULE cut(X) IS FROM X AND X � Y INFER Y
    
IDENTITY hyp
CUT cut

/* I think we have weakening.  I hope we do, because otherwise theorem application is difficult */
RULE weaken(X) IS FROM Y INFER X � Y
WEAKEN weaken

RULE "P�(�x.X) � P�X[x\\Y]"(Y) IS FROM P�(�x.X) INFER P�X[x\Y]

