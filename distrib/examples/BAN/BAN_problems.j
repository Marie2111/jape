/* $Id$ */

CONJECTUREPANEL Conjectures IS
  
  THEOREMS "Otway-Rees" ARE
  		S�(A,S)�Kas, S�({Na+Nc}Kas+{Nb+Nc}Kbs) � S�A�(Na+Nc)
  AND	S�(B,S)�Kbs, S�({Na+Nc}Kas+{Nb+Nc}Kbs) � S�B�(Nb+Nc)
  AND	A�(A,S)�Kas, A�(�k.S�(A,B)�k), A�#Na, A�{Na+(A,B)�Kab+B�Nc}Kas � A�(A,B)�Kab
  AND	B�(B,S)�Kbs, B�(�k.S�(A,B)�k), B�#Nb, B�({Na+(A,B)�Kab+B�Nc}Kas + {Nb+(A,B)�Kab+A�Nc}Kbs) � B�(A,B)�Kab
  AND	A�(A,S)�Kas, A�(�x.S�B�x), A�#Na, A�#Nc, A�{Na+(A,B)�Kab+ B�Nc}Kas � A�B�Nc
  AND	B�(B,S)�Kbs, B�(�x.S�A�x), B�#Nb, B�({Na+(A,B)�Kab+B�Nc}Kas + {Nb+(A,B)�Kab+A�Nc}Kbs) � B�A�Nc
  END
  
  THEOREMS "Needham-Schroeder" ARE
  		A�(A,S)�Kas, A�(�k.S�#((A,B)�k)), A�#Na, A�{Na+(A,B)�Kab+#((A,B)�Kab)+{(A,B)�Kab}Kbs}Kas � A�#((A,B)�Kab)
  AND	A�(A,S)�Kas, A�(�k.S�(A,B)�k), A�#Na, A�#((A,B)�Kab), A�{Na+(A,B)�Kab+#((A,B)�Kab)+{(A,B)�Kab}Kbs}Kas � A�(A,B)�Kab
  AND	B�(B,S)�Kbs, B�(�k.#((A,B)�k)), B�{(A,B)�Kab}Kbs � B�(A,B)�Kab
  AND	A�#((A,B)�Kab), A�(A,B)�Kab, A�{Nb+(A,B)�Kab}Kab � A�B�(A,B)�Kab
  AND	B�(A,B)�Kab, B�(�k.#((A,B)�k)), B�{Nb+(A,B)�Kab}Kab � B�A�(A,B)�Kab
  END
  
  /* THEOREMS Kerberos ARE
  		A�{Ts+(A,B)�Kab+{Ts,(A,B)�Kab}Kbs}Kas
  		B�({Ts,(A,B)�Kab}Kbs+{Ta,(A,B)�Kab}Kab from A)
  		A�{Ta,(A,B)�Kab} from B
  END */
END
