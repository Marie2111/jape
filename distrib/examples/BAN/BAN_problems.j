/* $Id$ */

CONJECTUREPANEL Conjectures IS
  THEOREMS "Otway-Rees" ARE
  		S � (A,S) � Kas, S � ({Na+Nc}Kas + {Nb+Nc}Kbs) � S � A � (Na+Nc)
  AND	S � (B,S) � Kbs, S � ({Na+Nc }Kas + {Nb+Nc}Kbs) � S � B � (Nb+Nc)
  AND	A � (A,S) � Kas, �x . A � S � (A,B) � x, A � #Na, A � {Na + (A,B)�Kab + B�Nc}Kas � A � (A,B) � Kab
  AND	B � (B,S) � Kbs, �x . B � S � (A,B) � x, B � #Nb, B � ({Na + (A,B)�Kab + B�Nc}Kas + {Nb + (A,B)�Kab + A�Nc}Kbs)
  		� B � (A,B) � Kab
  AND	A � (A,S) � Kas, �x . A � S � B �x, A � #Na, A � #Nc, A � {Na + (A,B)�Kab + B�Nc}Kas � A � B � Nc
  AND	B � (B,S) � Kbs, �x . B � S � A � x, A � #Na, B � #Nb, B � ({Na + (A,B)�Kab + B�Nc}Kas + {Nb + (A,B)�Kab + A�Nc}Kbs)
  		� B � A � Nc
  END
END
