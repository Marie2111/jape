/* $Id$ */

CONJECTUREPANEL Conjectures IS
		S � (A,S) � Kas, S � ({Na+Nc}Kas + {Nb+Nc}Kbs) � S � A � (Na+Nc)
AND		S � (B,S) � Kbs, S � ({Na+Nc }Kas + {Nb+Nc}Kbs) � S � B � (Nb+Nc)
AND		A � (A,S) � Kas, � K . A � S � (A,B) � K, A � #Na, A � {Na + (A,B)�Kab + B�Nc}Kas � A � (A,B) � Kab
AND		B � (B,S) � Kbs, � K . B � S � (A,B) � K, B � #Nb, B � ({Na + (A,B)�Kab + B�Nc}Kas + {Nb + (A,B)�Kab + A�Nc}Kbs)
		� B � (A,B) � Kab
AND		A � (A,S) � Kas, � X . A � S � B � X, A � #Na, A � #Nc, A � {Na + (A,B)�Kab + B�Nc}Kas � A � B � Nc
AND		 B � (B,S) � Kbs, � X . B � S � A � X, A � #Na, B � #Nb, B � ({Na + (A,B)�Kab + B�Nc}Kas + {Nb + (A,B)�Kab + A�Nc}Kbs)
		� B � A � Nc
END
