/*
        Some problems, originally cribbed from MacLogic

       $Id$
       
*/

/* 14/ix/92 - RB tidied up some of the provisos in later problems, and can't prove
        17, 21, 24, 26, 41 (or dnegh, dnegh2) using aipc rules.
        
        37 as originally stated was false, RB believes; he also believes that it 
        was probably intended to be stated as 37a.  Or maybe 37b
        
        This activity showed up some problems with proviso simplification/interpretation, 
        q.v. elsewhere.
 */

CONJECTUREPANEL "Conjectures"
  THEOREMS PropositionalProblems ARE
  	P�(Q�R)			� (P�Q)�(P�R)
  AND P�(Q�R), Q 		� P�R
  AND R�S			� (P�R) � (P�S)
  AND P�(P�Q)			� P�Q
  AND P				� Q�(P � Q)
  AND P�(Q�R)			� (P�Q)�R
  AND P�Q,P�R			� P�Q�R
  AND P�(Q�R)			� (P�Q) � R
  AND P�(Q�R)			� (P�Q) � (P�R)
  AND P�(Q�R)			� (P�Q) � (P�R)
  AND P�S,Q� �S		� �(P�Q)
  AND P�Q, Q� �P		� �P
  AND P� ( Q�R )		� ( P�Q ) � ( P�R )
  AND (P�Q) � (Q�R), �R	� �P
  AND P�Q,�Q			� (���P)�Q
  AND P�Q				� �(P � �Q)
  AND P�Q,Q� �R		� R � �P
  AND P�Q,�P			� Q
  AND �(P�Q)			� �P � �Q
  AND �P � �Q			� �(P�Q)
  AND �(P�Q)			� �P � �Q
  AND �P � �Q			� �(P�Q)
  AND 				� �(P � �P)
  AND 				� ((P � Q) � P) � P
  AND 				� (P � �P) � Q
  AND P� �(Q�R)		� (P�Q) � (P� �R)
  AND �(P�(Q�R)) 		� (Q�R)�P
  
  AND �x.�Q(x),  P�(�x.Q(x))			� �P
  AND P��P, �x.P�Q(x), �x. �P�Q(x) 	� �x.Q(x)		WHERE x NOTIN P END
  AND R��R, �x.R�S(x), �x. �R�S(x)	� �x.S(x)
  AND �x.P(x)�Q(x), �x.Q(x)�R(x) 		� �x.P(x)�R(x)
  AND �x.P(x)�R(x), �x.Q(x)� �R(x)   	� �x.(P(x)��Q(x)) � (Q(x)��P(x))
  AND S(m,n), �x.P(x) � �S(x,n) 		� �P(m)
  AND �x.P(x)�Q(x), �x.R(x)��Q(x)   	� �x.R(x)��P(x)
  AND �x.P(x)�Q(x)			  		� �x.P(x)
  AND �x.P(x)�Q(x)			  		� �x.Q(x)�P(x)  
  AND �x.P(x)��Q(x), �x.P(x)�R(x)  	� �x.R(x)��Q(x)
  AND (�x.Q(x)) � (�y.�Q(y)) 			� �(�z.Q(z))
  AND (�x.Q(x)) � (�y.�Q(y)) 			� �z.�Q(z)
  AND (�x.P(x)) � (�y.�P(y)) 			� �(�z.P)
  AND �x.�P(x) 						� �(�x.P(x))
  AND �x.P(x)�Q 					� (�x.P(x))�Q
  AND �x.S(x) � ((�P(x)��Q(x)) � R(x)) 	� �x.(S(x)��R(x))�(P(x)�Q(x))
  
  AND ��P 			� P
  AND P 			� ��P
  AND �x.�y.P 		� �y.�x.P		WHERE x NOTIN y END
  AND �x.�y.Q 		� �y.�x.Q
  AND �x.�y.P(x,y) 	� �y.�x.P(x,y)
  AND �x.�y.P(x,y) 	� �v.�u.P(u,v)
  AND �x.P(x)		� �y.P(y) 
  AND �x.P(x) 		� �y.P(y)
  AND �y.P(y) 		� �x.P(x)
  END
END
