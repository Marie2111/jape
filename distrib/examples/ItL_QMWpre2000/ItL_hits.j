/* $Id$ */

HYPHIT	P     � P	IS hyp       
HYPHIT	P�Q � R	IS ALT	(SEQ "�-E(L)" (hyp (P�Q)))
                                           	(SEQ "�-E(R)" (hyp (P�Q)))
                                           	(SEQ cut "�-E(L)" (hyp (P�Q)) cut "�-E(R)" (hyp (P�Q)))
HYPHIT	P�Q  � R	IS "�-Eforward"  (P�Q)
HYPHIT	P�Q  � R	IS ForwardUncut "�-E"  (P�Q)
HYPHIT	��P   � Q	IS ForwardCut "�-E"   (��P)
HYPHIT	�x.P � Q	IS ForwardCut "�-E"  (�x.P)
HYPHIT	�x.P � Q	IS ForwardUncut "�-E"  (�x.P)

CONCHIT	Q�R	IS "�-I"
CONCHIT	Q�R	IS ALT (SEQ "�-I(L)" hyp) (SEQ "�-I(R)" hyp)
CONCHIT	Q�R	IS "�-I"      
CONCHIT	�Q	IS "�-I"       
CONCHIT	�x.Q	IS "�-I"  
CONCHIT	�x.Q	IS "�-I"  
