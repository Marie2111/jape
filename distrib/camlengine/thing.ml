(* $Id$ *)

module type T =
  sig
    type term
    and vid
    and idclass
    and resnum
    and name
    and paraparam
    and proviso
    and seq
    and tactic
    type cxt and ('a, 'b) mapping
    type thing =
        Rule of
          ((paraparam list * (bool * proviso) list * seq list * seq) * bool)
      | Theorem of (paraparam list * (bool * proviso) list * seq)
      | Tactic of (paraparam list * tactic)
      | Macro of (paraparam list * term)
    type thingplace = InMenu of name | InPanel of name | InLimbo
    exception Fresh_ of string list exception CompileThing_ of string list
    val thingstring : thing -> string
    val freshThingtoapply :
      bool -> name -> cxt -> term list ->
        (cxt * (term, term) mapping * (resnum list * resnum list) * thing)
          option
    val freshThingtosubst :
      bool -> name -> cxt -> (term * term) list ->
        (cxt * (term, term) mapping * (resnum list * resnum list) * thing)
          option
    val freshThingtoprove : name -> thing option
    val freshGiven :
      bool -> seq -> cxt -> cxt * (resnum list * resnum list) * seq
    val rearrangetoResolve : seq list -> seq -> seq list * seq
    val instantiateRule :
      (term, term) mapping -> (bool * proviso) list -> seq list -> seq ->
        (term * term) list * (bool * proviso) list * seq list * seq
    val compiletoprove :
      proviso list * seq list * seq -> (bool * proviso) list * seq list * seq
    val formulageneralisable : paraparam list -> term -> bool
    val addthing : name * thing * thingplace -> unit
    val thingnamed : name -> (thing * thingplace) option
    val thinginfo : name -> (thing * thingplace) option
    (* including invisible provisos *)
       
    val clearthings : unit -> unit
    val thingnames : unit -> name list
    val thingstodo : unit -> bool
    type structurerule =
        CutRule
      | LeftWeakenRule
      | RightWeakenRule
      | IdentityRule
      | TransitiveRule
      | ReflexiveRule
    val addstructurerule : structurerule -> name -> bool
    val clearstructurerules : unit -> unit
    val isstructurerule : structurerule -> name -> bool
    val wehavestructurerule : structurerule -> string list option -> bool
    val structurerulestring : structurerule -> string
    val uniqueCut : unit -> name option
    val isRelation : term -> bool
    val numberrule : seq list * seq -> seq list * seq
    val numberforproof : seq list * seq -> seq list * seq
    val thingdebug : bool ref
    val thingdebugheavy : bool ref
    val autoAdditiveLeft : bool ref
    val autoAdditiveRight : bool ref
    val leftcontextname : unit -> string option
  end
(* $Id$ *)

module M : T =
  struct
    open Listfuns
    open Mappingfuns
    open Optionfuns
    open Stringfuns
    open Idclass
    open Term
    open Predicate
    open Match
    open Paraparam
    open Proviso
    open Sequent
    open Context
    open Rewrite
    
    type tactic = tactic and name = name
    
    let thingdebug = ref false
    let thingdebugheavy = ref false
    (* this is what we deal in *)
    type ruledata = paraparam list * (bool * proviso) list * seq list * seq
    type thmdata = paraparam list * (bool * proviso) list * seq
    type thing =
        Rule of (ruledata * bool)
      | Theorem of thmdata
      | Tactic of (paraparam list * tactic)
      | Macro of (paraparam list * term)
    (* this is what we store *)
    type storedthing =
        Rawthing of thing
      | CookedRule of ((term list * ruledata) * (term list * ruledata) * bool)
      | CookedTheorem of ((term list * ruledata) * (term list * ruledata))
    type thingplace = InMenu of name | InPanel of name | InLimbo
    let argliststring = termliststring
    let mapliststring =
      bracketedliststring (pairstring termstring termstring ",") ","
    let paramliststring = bracketedliststring paraparamstring ","
    let provisoliststring =
      bracketedliststring
        (pairstring (string_of_int : bool -> string) provisostring ",") " AND "
    let rec antecedentliststring heavy =
      bracketedliststring (if heavy then smlseqstring else seqstring) " AND "
    let rec consequentstring heavy = if heavy then smlseqstring else seqstring
    let rec ruledatastring heavy r =
      quadruplestring paramliststring provisoliststring
        (antecedentliststring heavy) (consequentstring heavy) ", " r
    let rec thmdatastring heavy t =
      triplestring paramliststring provisoliststring (consequentstring heavy)
        ", " t
    let rec thingstring =
      function
        Rule r ->
          "Rule" ^
            pairstring (ruledatastring false) (string_of_int : bool -> string)
              "," r
      | Theorem t -> "Theorem" ^ thmdatastring false t
      | Tactic t -> "Tactic" ^ pairstring paramliststring tacticstring ", " t
      | Macro m -> "Macro" ^ pairstring paramliststring termstring ", " m
    let rec cookedstring f = pairstring argliststring f ","
    let rec doublestring f = pairstring f f ","
    let rec storedthingstring =
      function
        Rawthing t -> ("Rawthing(" ^ thingstring t) ^ ")"
      | CookedRule r ->
          "CookedRule" ^
            triplestring (cookedstring (ruledatastring false))
              (cookedstring (ruledatastring false))
              (string_of_int : bool -> string) "," r
      | CookedTheorem t ->
          "CookedTheorem" ^
            doublestring (cookedstring (ruledatastring false)) t
    let rec thingplacestring =
      function
        InMenu s -> "InMenu " ^ namestring s
      | InPanel s -> "InPanel" ^ namestring s
      | InLimbo -> "InLimbo"
    let resnumbase = 1
    (* In numbering resources the number passed in is the next free number.
     * We renumber starting with resnumbase, so no resource will have a smaller
     * number than that.
     *)
    (* This function is about numbering rules, where we want to give resources
     * copied from consequent to antecedent the same number.  E.g. in
     * 
     *                      X |- P  X |- P->Q
     *                      ----------------- (->-E)
     *                             X |- Q
     *
     * all the elements (P, P->Q, Q) should have distinct numbers, but in
     *
     *                     X |- C  X, C |- B
     *                     ----------------- (cut)
     *                          X |- B
     *
     * the B in the top line should share a resource number with the B in the 
     * bottom line, and in
     *
     *                    X, Ax.P, P[x\c] |- Q
     *                    -------------------- (A|-)
     *                      X, Ax.P |- Q
     *
     * the Qs should share a resource number, as should the Ax.Ps.  But 
     * inheritance should only be from bottom to top, so the Cs in the cut don't
     * share a resource number (is this what we want? I hope so).  Inheritance
     * is also only from left to left or right to right: if a formula appears on
     * one side in the consequent and the other in an antecedent, those instances
     * won't share a resource number.  Repeated resources do share numbers, as for
     * example in 
     *
     *                    X, B, B |- C
     *                    ------------ (contract |-)
     *                      X, B |- C
     *
     * If there is more than one occurrence of a formula on the same side of 
     * the consequent as, for example, in
     *
     *                    X, B |- C
     *                   ------------ (no name - never seen it )
     *                   X, B, B |- C
     *
     * then the algorithm won't give them the same number.  Hope all this is
     * what is needed -- expect experience to decide.
     *
     * RB 26/vii/96
     *)
    (* Experience hasn't got very far yet, but it has discovered that it is 
     * necessary to number all things in the consequent with ResUnknowns, all 
     * similar things in the antecedents similarly and everything else with 
     * Resnums
     * RB 19/ix/96
     *)
    (* Experience with multiplicative rules and drag-and-drop shows that it is
     * important that duplicated resources (as in contract) should be given
     * _different_ numbers.  This means that the interface implementation of
     * dNd has to be complicated (sigh).
     * RB 14/viii/97
     *)
    
    (* we number rules starting from 1, so that seqvars and Nonums can be 
     * described as zeros to the uninitiated
     *)
    let rec numberrule (antes, conseq) =
      let rec numberseq fld =
        fun R n leftenv rightenv ->
          fun (Seq (st, hs, gs) as seq) ->
            let rec numberel (el, (n, oldenv, newenv, es)) =
              match el with
                Element (_, _, t) ->
                  begin match at (oldenv, t) with
                    Some m ->
                      n, ( -- ) (oldenv, [t]), newenv,
                      registerElement (ResUnknown m, t) :: es
                  | None ->
                      n + 1, oldenv, ( ++ ) (newenv, ( |-> ) (t, n)),
                      registerElement (R n, t) :: es
                  end
              | _ -> n, oldenv, newenv, el :: es
            in
            match hs, gs with
              Collection (_, hkind, hes), Collection (_, gkind, ges) ->
                let (n, _, newleftenv, hes) =
                  fld numberel hes (n, leftenv, empty, [])
                in
                let (n, _, newrightenv, ges) =
                  fld numberel ges (n, rightenv, empty, [])
                in
                n, newleftenv, newrightenv,
                Seq
                  (st, registerCollection (hkind, hes),
                   registerCollection (gkind, ges))
            | _ ->
                raise
                  (Catastrophe_
                     ["in numberseq argument "; seqstring seq;
                      " exploded into ("; smltermstring hs; ",";
                      smltermstring gs; ")"])
      in
      let (n, leftenv, rightenv, conseq') =
        numberseq nj_fold ResUnknown 1 empty empty conseq
      in
      let rec rvfld f xs z =
        let (n, old, new__, ys) = nj_revfold f xs z in n, old, new__, List.rev ys
      in
      let (n, antes') =
        nj_fold
          (fun (seq, (n, seqs)) ->
             let (n, _, _, seq') =
               numberseq rvfld Resnum n leftenv rightenv seq
             in
             n, seq' :: seqs)
          antes (n, [])
      in
      (* desperation ...
      if !thingdebug then
        let val p = pairstring (antecedentliststring true) (consequentstring true) "," in
            consolereport ["numberrule ", p (antes,conseq), " => ", p (antes',conseq')]
        end
      else (); 
      ... end desperation *)
      antes', conseq'
    (* Once a rule has been numbered as above it is a trivial matter to renumber
     * it.  This function is given a number to start from; it returns the 
     * maximum resource number in the new sequent, and a list of all its 
     * ResUnknowns.
     *)
    (* because we start numbering from 1 (so that segvars and Nonums can be described
     * as zeros to the non-initiate), we adjust the numbering of the new sequent
     * to avoid gaps in the number order
     *)
    let rec numberforapplication n (antes, conseq) =
      let rec renumberseq n =
        fun (Seq (st, hs, gs) as seq) ->
          let rec new__ m = n + m - 1 in
          (* that's the adjustment *)
          let rec renumberel (el, (m, rs, els)) =
            match el with
              Element (_, ResUnknown m', t) ->
                let r' = ResUnknown (new__ m') in
                max (m) (new__ m'),
                (if member (r', rs) then rs else r' :: rs),
                registerElement (r', t) :: els
            | Element (_, Resnum m', t) ->
                max (m) (new__ m'), rs,
                registerElement (Resnum (new__ m'), t) :: els
            | _ -> m, rs, el :: els
          in
          match hs, gs with
            Collection (_, hkind, hes), Collection (_, gkind, ges) ->
              let (m, leftrs, hes) = nj_fold renumberel hes (0, [], []) in
              let (m', rightrs, ges) = nj_fold renumberel ges (0, [], []) in
              max (m) (m'), (leftrs, rightrs),
              Seq
                (st, registerCollection (hkind, hes),
                 registerCollection (gkind, ges))
          | _ ->
              raise
                (Catastrophe_
                   ["in renumberseq argument "; seqstring seq;
                    " exploded into ("; smltermstring hs; ",";
                    smltermstring gs; ")"])
      in
      let (m, rs, conseq') = renumberseq n conseq in
      let (m, antes') =
        nj_fold
          (fun (seq, (m, seqs)) ->
             let (m', _, seq') = renumberseq n seq in
             max (m) (m'), seq' :: seqs)
          antes (m, [])
      in
      let res = m + 1, rs, antes', conseq' in(* desperation ... 
      if !thingdebug then
        consolereport ["numberforapplication ", string_of_int n, " ",
          pairstring (antecedentliststring true) (consequentstring true) ", "
                     (antes,conseq),
          " => ", 
          quadruplestring 
            string_of_int 
            let val p = bracketedliststring resnumstring "," in 
                pairstring p p ","
            end
            (antecedentliststring true) (consequentstring true) ", "
            res
        ]
      else ();
      ... end desperation *)
       res
    (* When we _prove_ a theorem, all the ResUnknowns must become Resnums 
     * For the moment we don't know what to do with the antecedents - so we leave
     * them alone.
     *)
    let rec numberforproof (antes, conseq) =
      let rec renumberel el =
        match el with
          Element (_, ResUnknown r, t) -> registerElement (Resnum r, t)
        | el -> el
      in
      let conseq' =
        match conseq with
          Seq (st, Collection (_, hkind, hes), Collection (_, gkind, ges)) ->
            Seq
              (st, registerCollection (hkind, (renumberel <* hes)),
               registerCollection (gkind, (renumberel <* ges)))
        | Seq (st, hs, gs) ->
            raise
              (Catastrophe_
                 ["in numberforproof argument "; seqstring conseq;
                  " exploded into ("; smltermstring hs; ","; smltermstring gs;
                  ")"])
      in
      antes, conseq'
    (* this function to help FIND and FLATTEN tactic.  What it does is to
     * check that a particular variable name v is (a) FormulaClass and 
     * (b) if in the list of parameters params, then is not listed as
     * Objectparam or Abstractionparam.
     * Thus you can tell that an associative law is really general.  I think.
     *)
    let rec formulageneralisable params v =
      let rec ok a1 a2 =
        match a1, a2 with
          vc, Objectparam vc' -> vc <> vc'
        | vc, Abstractionparam vc' -> vc <> vc'
        | _, _ -> true
      in
      match v with
        Id (_, v, FormulaClass) -> _All (ok (v, FormulaClass), params)
      | Unknown (_, v, FormulaClass) -> _All (ok (v, FormulaClass), params)
      | _ -> false
    exception Fresh_ of string list exception CompileThing_ of string list
    let autoAdditiveLeft = ref false
    let autoAdditiveRight = ref false
    let rec findhiddenprovisos (b, ts) ps =
      (* first look for parallel bindings *)
      let multibinders =
        let dmerge = sortedmerge (earlierlist earliervar) in
        let rec dbs t =
          sort (earlierlist earliervar)
            (foldterm
               (function
                  Subst (_, _, P, (_ :: _ :: _ as vts)), qs ->
                    Some
                      (nj_fold dmerge
                         ([sort earliervar ((fst <* vts))] ::
                            (dbs <* P :: (snd <* vts)))
                         qs)
                | Binding (_, ((_ :: _ :: _ as bs), ss, us), _, _), qs ->
                    Some
                      (nj_fold dmerge
                         ([sort earliervar bs] :: (dbs <* ss) @
                            (dbs <* us))
                         qs)
                | _ -> None)
               [] t)
        in
        nj_fold dmerge ((seqvars dbs dmerge <* b :: ts)) []
      in
      let diffbinders =
        nj_fold (fun (x, y) -> x @ y) ((allpairs <* multibinders)) ps
      in
      (* and then look for skipped binders - things like Ax.Ay.x 
       * and now (that I've tried it) also look for Ax.Ay.z
       *)
      let allbinders =
        nj_fold bmerge ((seqvars varbindings bmerge <* b :: ts)) []
      in
      let skipbinders =
        let rec sks (v, bss) =
          let rec skf =
            function
              [] -> if idclass v = VariableClass then Some [] else None
            | b :: bs ->
                if member (v, b) then Some []
                else (skf bs &~~ (fun bs' -> Some (b :: bs')))
          in
          let bss' =
            nj_fold
              (fun (bs, rs) ->
                 match skf bs with
                   None -> rs
                 | Some [] -> rs
                 | Some bs' -> bs' :: rs)
              bss []
          in
          let rec mkpairs b = ((fun v' -> v, v') <* b) in
          List.concat (((fun bs -> List.concat ((mkpairs <* bs))) <* bss'))
        in
        List.concat ((sks <* allbinders))
      in
      diffbinders @ skipbinders
    (* designed to be (NJ) folded *)
    let rec findpredicatebindings isabstraction =
      fun (Seq (st, lhs, rhs), pbs) ->
        let g = foldterm (findpredicates isabstraction []) in
        g (g pbs lhs) rhs
    let rec compilepredicates isabstraction env =
      fun (Seq (st, lhs, rhs)) ->
        let f =
          compilepredicate isabstraction
            (fun t -> try__ (fun (_, vs) -> vs) (at (env, t)))
        in
        Seq (st, mapterm f lhs, mapterm f rhs)
    let rec checkarg var arg =
      begin try checkTacticTerm arg with
        Tacastrophe_ ss ->
          raise (Fresh_ ("argument " :: termstring arg :: " contains " :: ss))
      end;
      if specialisesto (idclass var, idclass arg) then ()
      else
        raise
          (Fresh_
             ["argument "; termstring arg; " doesn't fit parameter ";
              termstring var])
    let rec freshc defcon cxt env params args =
      let F = freshc defcon in
      let rec inextensible c v =
        raise
          (Fresh_
             ["parameter "; v; " was classified "; idclassstring c;
              " - you must use a CLASS "; idclassstring c; " identifier"])
      in
      let rec newVID cxt c v =
        if isextensibleID v then freshVID cxt c v else inextensible c v
      in
      let rec extend con bits arg =
        let var = con bits in
        checkarg var arg; ( ++ ) (env, ( |-> ) (var, arg))
      in
      let rec newname new__ con con' (v, c) vs =
        let (cxt', v') = new__ cxt c v in
        F (cxt', ( ++ ) (env, ( |-> ) (con (v, c), con' (v', c))), vs, [])
      in
      let rec usearg con vc vs arg args =
        F (cxt, extend con vc arg, vs, args)
      in
      match params, args with
        [], [] -> cxt, env
      | [], _ :: _ -> raise (Fresh_ ["too many arguments provided"])
      | Ordinaryparam vc :: vs, [] -> newname newVID registerId defcon vc vs
      | Ordinaryparam vc :: vs, arg :: args ->
          usearg registerId vc vs arg args
      | Objectparam (v, c) :: vs, [] ->
          if isextensibleID v then
            (* trying freshproofvar again *)
            newname freshproofvar registerId fst (v, c) vs
          else inextensible c v
      | Objectparam vc :: vs, arg :: args -> usearg registerId vc vs arg args
      | Unknownparam vc :: vs, [] ->
          newname newVID registerUnknown registerUnknown vc vs
      | Unknownparam vc :: vs, arg :: args ->
          usearg registerUnknown vc vs arg args
      | Abstractionparam vc :: vs, [] ->
          newname newVID registerId defcon vc vs
      | Abstractionparam vc :: vs, arg :: args ->
          usearg registerId vc vs arg args
    (* infix -- ++ moved out then deleted for OCaml; hope infixr above will do *)
              
    let rec extraVIDs params args bodyVIDs =
      let rec ( -- ) (xs, ys) =
        listsub (fun (x, y) -> x = y : vid * vid -> bool) xs ys
      in
      let rec ( ++ ) (xs, ys) = mergeVIDs xs ys in
      let argVIDs =
        nj_fold (fun (x, y) -> ( ++ ) x y) ((termVIDs <* args)) []
      in
      let rec paramVIDs ps =
        orderVIDs (((fst <*> paramidbits) <* ps))
      in
      (* desperation ...
      if !thingdebug then 
        consolereport["bodyVIDs are ", 
                      bracketedliststring (fn x => x) "," bodyVIDs,
                      "; paramVIDs are ", 
                      bracketedliststring (fn x => x) "," (paramVIDs params),
                      "; argVIDs are ", 
                      bracketedliststring (fn x => x) "," argVIDs
                     ]
       else ();
       ... end desperation *)
      ( -- ) (bodyVIDs, ( ++ ) (paramVIDs params, argVIDs))
    let rec allparams params allvs =
      params @
        listsub
          (function
             Unknownparam v1, Unknownparam v2 ->
               fst v1 = fst v2
           | Unknownparam v1, _ -> false
           | _, Unknownparam v2 -> false
           | v1, v2 ->
               fst (paramidbits v1) = fst (paramidbits v2))
          allvs params
    let rec extraBag () = autoID (BagClass FormulaClass) "extraBag"
    let rec leftcontextname () =
      if !autoAdditiveLeft then Some (extraBag ()) else None
    let rec newvar con class__ (vid, vars) =
      let vid = uniqueVID class__ ((vartoVID <* vars)) [] vid in
      let v = con (vid, class__) in v, tmerge ([v], vars)
    let rec extend a1 a2 =
      match a1, a2 with
        sv, Collection (_, BagClass FormulaClass, es) ->
          registerCollection (BagClass FormulaClass, sv :: es)
      | sv, c -> c
    let rec extensible c =
      match c with
        Collection (_, BagClass FormulaClass, es) ->
          not
            (List.exists
               (function
                  Segvar (_, [], Unknown _) -> true
                | Segvar (_, [], Id (_, v, _)) -> isextensibleID v
                | _ -> false)
               es)
      | _ -> false
    let rec ehb vars c =
      if extensible c then
        let (v, vars) =
          newvar registerId (BagClass FormulaClass) (extraBag (), vars)
        in
        let sv = registerSegvar ([], v) in Some (vars, sv, extend sv c)
      else None
    exception BadAdditivity_ of string list
    let rec augment el er (conseq, antes, vars) =
      let rec f extendp getside setside (conseq, antes, vars) =
        if extendp then
          match ehb vars (getside conseq) with
            Some (vars, sv, side) ->
              let antes =
                ((fun s ->
                      let side = getside s in
                      if extensible side then setside s (extend sv side)
                      else
                        raise
                          (BadAdditivity_
                             ["antecedent "; seqstring s;
                              " isn't extensible"])) <*
                   antes)
              in
              setside conseq side, antes, vars
          | None ->
              raise
                (BadAdditivity_
                   ["consequent "; seqstring conseq; " isn't extensible"])
        else conseq, antes, vars
      in
      let rec lhs = fun (Seq (_, lhs, _)) -> lhs in
      let rec setlhs = fun (Seq (st, _, rhs)) lhs -> Seq (st, lhs, rhs) in
      let rec rhs = fun (Seq (_, _, rhs)) -> rhs in
      let rec setrhs = fun (Seq (st, lhs, _)) rhs -> Seq (st, lhs, rhs) in
      let (conseq, antes, vars) = f el lhs setlhs (conseq, antes, vars) in
      let (conseq, antes, vars) = f er rhs setrhs (conseq, antes, vars) in
      conseq, antes, vars
    (* We don't want to do a lot of work when we apply a rule, so we 
     * compile it the first time it's called for, and use it ever after.
     *)
    let rec compileR el er (params, provisos, antes, conseq) =
      let (antes, conseq) = numberrule (antes, conseq) in
      let bodyvars =
        nj_fold tmerge ((seqvars termvars tmerge <* conseq :: antes)) []
      in
      (* translate predicates *)
      let abstractions =
        nj_fold
          (function
             Abstractionparam vc, vcs -> vc :: vcs
           | _, vcs -> vcs)
          params []
      in
      let rec isabstraction =
        function
          Id (_, v, c) -> member ((v, c), abstractions)
        | _ -> false
      in
      let conseq_pbs =
        try
          discardzeroarities
            (findpredicatebindings isabstraction (conseq, []))
        with
          Predicate_ ss -> raise (CompileThing_ ss)
      in
      let all_pbs =
        try
          discardzeroarities
            (nj_fold (findpredicatebindings isabstraction) antes conseq_pbs)
        with
          Predicate_ ss -> raise (CompileThing_ ss)
      in
      let _ =
        if !thingdebug then
          consolereport ["all_pbs = "; predicatebindingstring all_pbs]
      in
      (* now we have a list of predicates, 
       * each paired with a list of arguments,
       * each paired with a list of binding contexts in which that
       * predicate/argument pair occurs.
       *
       * find all the contexts and deny that any binder
       * occurs in any of the predicates it binds.
       *)
      let rec findbinders =
        fun ((P, abss), ps) ->
          let rec g (ts, bss) =
            let vs = nj_fold (sortedmerge earliervar) bss [] in
            ((fun v -> v, P) <* vs)
          in
          List.concat ((g <* abss)) @ ps
      in
      let proofps =
        sortunique (earlierpair (earliervar, earliervar))
          (nj_fold findbinders all_pbs [])
      in
      (* for application:
       * translate predicates into substitutions, but first make a
       * judicious choice of substitution variables.
       *)
      let rec findsubstvars def =
        fun ((P, abss), (vars, env)) ->
          match at (env, P) with
            Some _ -> vars, env
          | None ->
              match findpredicatevars abss with
                Some bs -> vars, ( ++ ) (env, ( |-> ) (P, (false, bs)))
              | None ->
                  if def then
                    (* make up names *)
                    let (ts, _) = List.hd abss in
                    let rec h (_, (vs, vars)) =
                      let (v, vars) =
                        newvar registerId VariableClass
                          (autoID VariableClass "predVar", vars)
                      in
                      v :: vs, vars
                    in
                    let (vs, vars) = nj_fold h ts ([], vars) in
                    vars, ( ++ ) (env, ( |-> ) (P, (true, vs)))
                  else vars, env
      in
      let (applybodyvars, firstenv) =
        nj_fold (findsubstvars false) conseq_pbs (bodyvars, empty)
      in
      let (applybodyvars, env) =
        nj_fold (findsubstvars true) all_pbs (applybodyvars, firstenv)
      in
      (* now filter out the provisos we don't want any more ... *)
      let applyps =
           (fun (x, P) ->
              match at (env, P) with
                Some (false, vs) -> not (member (x, vs))
              | Some (true, _) -> true
              | None ->
                  raise (Catastrophe_ ["bad env in filter predicateps"])) <|
           proofps
      in
      (* desperation ... *)
      let _ =
        if !thingdebug then
          consolereport
            ["proofps is ";
             bracketedliststring (pairstring termstring termstring ",") ", "
               proofps;
             " and env is ";
             mappingstring termstring
               (pairstring (string_of_int : bool -> string) termliststring ", ")
               env;
             " and applyps is ";
             bracketedliststring (pairstring termstring termstring ",") ", "
               applyps]
      in
      (* ... end desperation *)
      let objparams =
        mappingfuns.lfold
          (function
             (_, (true, bs)), vs -> bs @ vs
           | _, vs -> vs)
          [] env
      in
      (* and then go through the binders _again_ to find the implicit
       * provisos
       *)
      let proofps = findhiddenprovisos (conseq, antes) proofps in
      let applyps = findhiddenprovisos (conseq, antes) applyps in
      (* and that's it *)
      let rec makeprovisos ps =
        ((fun xy -> false, mkNotinProviso xy) <* ps) @ provisos
      in
      let
        (proofbodyvars, proofantes, proofconseq, proofprovisos, applybodyvars,
         applyantes, applyconseq, applyprovisos, applyparams)
        =
        bodyvars, antes, conseq, makeprovisos proofps, applybodyvars,
        (compilepredicates isabstraction env <* antes),
        compilepredicates isabstraction env conseq, makeprovisos applyps,
        params @
          nj_fold
            (function
               Id (_, v, c), ps -> Objectparam (v, c) :: ps
             | _, ps -> ps)
            objparams []
      in
      let _ =
        if !thingdebug then
          consolereport
            ["applyantes are "; bracketedliststring seqstring ", " applyantes;
             " and applyconseq is "; seqstring conseq]
      in
      (* augment apply version, if necessary, with Unknown Segvars *)
      let (applyconseq, applyantes, applybodyvars) =
        augment el er (applyconseq, applyantes, applybodyvars)
      in
      let rec mkvars vs =
        (isextensibleID <*> vartoVID) <| vs
      in
      (mkvars proofbodyvars, (params, proofprovisos, antes, conseq)),
      (mkvars applybodyvars,
       (applyparams, applyprovisos, applyantes, applyconseq))
    let rec compilething name thing =
      match thing with
        Rule (r, ax) ->
          let (r1, r2) =
            try compileR !autoAdditiveLeft !autoAdditiveRight r with
              CompileThing_ ss ->
                raise
                  (CompileThing_ ("Rule " :: namestring name :: ": " :: ss))
            | BadAdditivity_ ss ->
                raise
                  (CompileThing_
                     ("the autoAdditive mechanism can't be used with rule/theorem " :: namestring name :: " because " :: ss))
          in
          CookedRule (r1, r2, ax)
      | Theorem (params, provisos, bot) ->
          begin try
            CookedTheorem (compileR false false (params, provisos, [], bot))
          with
            CompileThing_ ss ->
              raise
                (CompileThing_ ("Theorem " :: namestring name :: ": " :: ss))
          end
      | _ -> Rawthing thing
    let relationpats : term list ref = ref []
    let rec isRelation t =
      List.exists (fun p -> opt2bool (match__ false p t empty)) !relationpats
    let rec registerRelationpat t =
      (* we assume it's the right shape ... *)
      if isRelation t then () else relationpats := t :: !relationpats
    (* this comes before the thingstore because of the call of erasestructurerule in
     * addthing
     *)
    type structurerule =
        CutRule
      | LeftWeakenRule
      | RightWeakenRule
      | IdentityRule
      | TransitiveRule
      | ReflexiveRule
    let rec structurerulestring sr =
      match sr with
        CutRule -> "CutRule"
      | LeftWeakenRule -> "LeftWeakenRule"
      | RightWeakenRule -> "RightWeakenRule"
      | IdentityRule -> "IdentityRule"
      | TransitiveRule -> "TransitiveRule"
      | ReflexiveRule -> "ReflexiveRule"
    let structurerules : (structurerule * name) list ref = ref []
    let rec clearstructurerules () = structurerules := []; relationpats := []
    let rec erasestructurerule name =
      structurerules := ((fun (_, n) -> n <> name) <| !structurerules)
    let rec isstructurerule kind name =
      List.exists (fun (k, n) -> (k, n) = (kind, name)) !structurerules
    let rec uniqueCut () =
      match
           (function
              CutRule, _ -> true
            | _ -> false) <|
           !structurerules
      with
        [_, r] -> Some r
      | _ -> None
    (* in an attempt to keep conjectures always in the order they were initially inserted, 
     * even though they may be altered by proofs (see addproof in prooftree.sml),
     * the thing store has an additional level of ref(..).
     * This is now obsolete, but I don't want to change it yet (RB 27/x/95)
     *)
    (* profiling showed that we were spending 55% of our time in compiledthinginfo; 
     * all that time was going into (!things at name).  So I used a simplestore instead.
     * Problem is that we no longer have an ordering, but I don't think that matters any 
     * more.
     * We no longer have the extra ref.
     *)
    let
      (clearthings, compiledthinginfo, compiledthingnamed, getthing,
       goodthing, badthing, thingnamed, thinginfo, addthing, thingnames,
       thingstodo)
      =
      let pst = pairstring storedthingstring thingplacestring ","
      and (lookup, update, delete, reset, sources, targets) =
        simplestore "thingstore" (triplestring namestring string_of_int pst ",")
          127
      (* why not? It can only grow :-) *)
      and hash = hashstring <*> namestring in
      let rec clearthings () = reset ()
      and compiledthinginfo name =
        let res =
          match lookup (hash name) name with
            Some (thing, place) as v ->
              begin match thing with
                Rawthing thing ->
                  let info = compilething name thing, place in
                  update (hash name) name info; Some info
              | _ -> v
              end
          | None ->
              if !thingdebug then
                consolereport
                  ["compiledthinginfo couldn't find "; namestring name];
              None
        in
        if !thingdebug then
          consolereport [" "; namestring name; " is "; optionstring pst res];
        res
      and compiledthingnamed name =
        (compiledthinginfo name &~~ (fun (thing, place) -> Some thing))
      and getthing trim name =
        match compiledthinginfo name with
          Some (Rawthing th, place) -> Some (trim th, place)
        | Some (CookedRule ((_, r), _, ax), place) ->
            Some (trim (Rule (r, ax)), place)
        | Some
            (CookedTheorem ((_, (params, provisos, _, conseq)), _), place) ->
            Some (trim (Theorem (params, provisos, conseq)), place)
        | None -> None
      and goodthing =
        function
          Theorem (params, provisos, seq) ->
            Theorem (params, fst <| provisos, seq)
        | Rule ((params, provisos, antes, conseq), ax) ->
            Rule
              ((params, fst <| provisos, antes, conseq), ax)
        | Tactic _ as t -> t
        | Macro _ as m -> m
      and badthing t = t in
      let thingnamed = getthing goodthing
      and thinginfo = getthing badthing in
      (* for _efficiency_, it would be best if we compiled things when they were
       * first used.  For _error reporting_, and for generally making sense, it is
       * best if they are compiled when put into place
       *)
      let rec addthing (name, thing, place) =
        let _ = erasestructurerule name in
        (* we aren't going to make THAT mistake! *)
        let newthing = compilething name (goodthing thing) in
        let newplace =
          match lookup (hash name) name with
            Some (_, oldplace) ->
              begin match place with
                InLimbo -> oldplace
              | _ -> place
              end
          | None -> place
        in
        (* here is where we ought to check other stuff that depends 
         * on this thing ...
         *)
        if !thingdebug then
          consolereport
            ["addthing ";
             triplestring namestring thingstring thingplacestring ","
               (name, thing, place);
             " was "; optionstring pst (lookup (hash name) name); "; is now ";
             pst (newthing, newplace)];
        update (hash name) name (newthing, newplace)
      and thingnames () = sources ()
      (* reverse so that we see things in their insertion order *)
      (* now no particular order -- does this matter? *)
      and thingstodo () = not (null (sources ())) in
      clearthings, compiledthinginfo, compiledthingnamed, getthing, goodthing,
      badthing, thingnamed, thinginfo, addthing, thingnames, thingstodo
    let rec var2param =
      function
        Id (_, v, c) -> Ordinaryparam (v, c)
      | Unknown (_, v, c) -> Unknownparam (v, c)
      | t ->
          raise
            (Fresh_
               ["unknown schematic variable "; termstring t;
                " in var list in freshRule"])
    let rec freshparamstouse vars args params =
      let paramsused =
        allparams params
          ((var2param <*
              (isextensibleID <*> vartoVID) <| vars))
      in
      let bodyVIDs = orderVIDs ((vartoVID <* vars)) in
      let ruleVIDs = extraVIDs paramsused args bodyVIDs in
      paramsused, ruleVIDs
    let rec env4Rule env args cxt defcon (paramsused, ruleVIDs) =
      let res =
        freshc defcon (plususedVIDs (cxt, ruleVIDs)) env paramsused
          (* this should read (take (List.length params) args)
           * .. but that stops me replaying proofs, so for the meantime ...
           *)
          (take (List.length paramsused) args)
      in
      if !thingdebug then
        consolereport
          ["applymap "; mappingstring termstring termstring env; " ";
           termliststring args; " "; "..cxt.. "; "..defcon.. ";
           "(..paramsused.., ..ruleVIDs..)"; " => ";
           pairstring cxtstring (mappingstring termstring termstring) ","
             res];
      res
    let rec instantiateRule env provisos antes conseq =
      let provisos' = ((fun (v, p) -> v, remapproviso env p) <* provisos) in
      let conseq' = remapseq env conseq in
      let antes' = (remapseq env <* antes) in
      (* give args back in the order received, not the mapping order *)
      let res = List.rev (rawaslist env), provisos', antes', conseq' in
      let show =
        triplestring provisoliststring (antecedentliststring !thingdebugheavy)
          (consequentstring !thingdebugheavy) ", "
      in
      if !thingdebug then
        consolereport
          ["instantiateRule "; mappingstring termstring termstring env; " ";
           provisoliststring provisos; " ";
           antecedentliststring !thingdebugheavy antes; " ";
           consequentstring !thingdebugheavy conseq; " "; " => ";
           quadruplestring mapliststring provisoliststring
             (antecedentliststring !thingdebugheavy)
             (consequentstring !thingdebugheavy) ", " res];
      res
    let rec freshRule
      env args cxt (params, provisos, antes, conseq) defcon
        (paramsused, ruleVIDs) =
      let (cxt', env) =
        freshc defcon (plususedVIDs (cxt, ruleVIDs)) env paramsused
          (* this should read (take (List.length params) args)
           * .. but that stops me replaying proofs, so for the meantime ...
           *)
          (take (List.length paramsused) args)
      in
      let provisos' = ((fun (v, p) -> v, remapproviso env p) <* provisos) in
      let conseq' = remapseq env conseq in
      let antes' = (remapseq env <* antes) in
      (* give args back in the order received, not the mapping order *)
      let res =
        List.rev (rawaslist env), cxt', (params, provisos', antes', conseq')
      in
      if !thingdebug then
        consolereport
          ["freshRule "; termliststring args; " "; "..cxt.. ";
           ruledatastring !thingdebugheavy (params, provisos, antes, conseq);
           " "; " => "; mappingstring termstring termstring env; "; ";
           triplestring mapliststring cxtstring
             (ruledatastring !thingdebugheavy) ", " res];
      res
    let rec renumberforuse args antes conseq cxt =
      (* renumber the sequent *)
      let (n, interesting_resources, antes, conseq) =
        numberforapplication (nextresnum cxt) (antes, conseq)
      in
      (* renumber Collection arguments *)
      let (n, args) =
        nj_fold
          (function
             Collection (_, k, es), (n, args) ->
               let (n, es) =
                 nj_fold
                   (function
                      Element (_, Nonum, t), (n, es) ->
                        n + 1, registerElement (ResUnknown n, t) :: es
                    | e, (n, es) -> n, e :: es)
                   es (n, [])
               in
               n, registerCollection (k, es) :: args
           | arg, (n, args) -> n, arg :: args)
          args (n, [])
      in
      let cxt = withresnum (cxt, n) in
      interesting_resources, args, antes, conseq, cxt
    let rec freshRuleshow name af cxt args vars rd res =
      if !thingdebug then
        begin
          let rec nocxtstring _ = "..cxt.. " in
          let rnl = bracketedliststring resnumstring "," in
          consolereport
            [name; " "; nocxtstring cxt; " "; af args; " ";
             termliststring vars; " "; ruledatastring !thingdebugheavy rd;
             " "; " => ";
             quadruplestring nocxtstring (mappingstring termstring termstring)
               (pairstring rnl rnl ",") (ruledatastring !thingdebugheavy) ", "
               res]
        end;
      res
    let rec freshRuletoapply
      cxt args vars (params, provisos, antes, conseq as rd) =
      let (interesting_resources, args, antes', conseq', cxt') =
        renumberforuse args antes conseq cxt
      in
      (* there ought to be a check on the number of arguments provided, just here *)
      let (cxt'', env) =
        env4Rule empty args cxt' registerUnknown
          (freshparamstouse vars args params)
      in
      freshRuleshow "freshRuletoapply" termliststring cxt args vars rd
        (cxt'', env, interesting_resources,
         (params, provisos, antes', conseq'))
    let rec freshRuletosubst
      cxt argmap vars (params, provisos, antes, conseq as rd) =
      let _ = List.iter (fun (var, arg) -> checkarg var arg) argmap in
      let argvars = (fst <* argmap) in
      let args = (snd <* argmap) in
      let rec bad w n vs =
        raise
          (Fresh_
             [liststring termstring " and " vs; " "; w; " not schematic "; n;
              " of the rule/theorem"])
      in
      let _ =
        match listsub (fun (x, y) -> x = y) argvars vars with
          [] -> ()
        | [v] -> bad "is" "name" [v]
        | vs -> bad "are" "names" vs
      in
      let (paramsused, ruleVIDs) = freshparamstouse vars args params in
      let (interesting_resources, args, antes', conseq', cxt') =
        renumberforuse args antes conseq cxt
      in
      (* ok, we're ready to roll.  _All we have to do is subtract argparams from
       * paramsused, and we are in business
       *)
      let (cxt'', env) =
        env4Rule (mkmap (List.rev ((argvars ||| args)))) [] cxt'
          registerUnknown
          (listsub (fun (p, v) -> fst (paramidbits p) = vartoVID v)
             paramsused argvars,
           ruleVIDs)
      in
      freshRuleshow "freshRuletosubst" mapliststring cxt argmap vars rd
        (cxt'', env, interesting_resources,
         (params, provisos, antes', conseq'))
    let rec fThmaors fR lw rw cxt args vars (params, provisos, _, conseq) =
      let (conseq, _, vars) = augment lw rw (conseq, [], vars) in
      let (cxt, env, resnums, (params, provisos, _, conseq)) =
        fR cxt args vars (params, provisos, [], conseq)
      in
      cxt, env, resnums, (params, provisos, conseq)
    (* mangled the next four lines to fit stupid SMLNJ 109 (I think) *)
    let rec freshTheoremtoapply lw rw cxt args vars rulestuff =
      fThmaors freshRuletoapply lw rw cxt args vars rulestuff
    let rec freshTheoremtosubst lw rw cxt args vars rulestuff =
      fThmaors freshRuletosubst lw rw cxt args vars rulestuff
    (* 1. This is a hack, to be used until I can work out how to program a general 
     *    resolution step as a tactic -- in particular, beware of 2a.
     * 2. It always succeeds, even if there are no lhs formulae which might make it useful,
     *    even if neither lhs nor rhs has any structure which would make it pointful,
     *    even if there isn't a cut rule or a weaken rule or whatever.
     * 2a.It only tells the truth if there is an additive cut rule and left weakening.
     * 3. It is only to be applied to rules and/or theorems which have already been 
     *    numbered for application, but haven't yet been instantiated.
     * 4. Once you've used it, don't forget to throw away the left-hand principals (first half
     *    of interesting_resources).
     *)
    let rec rearrangetoResolve antes =
      fun (Seq (st, lhs, rhs) as conseq) ->
        let rec extractsegv =
          function
            Collection (_, cc, els) ->
              let (segvs, els') = split issegvar els in cc, segvs, els'
          | t ->
              raise
                (Catastrophe_
                   ["can't happen rearrangetoResolve "; smltermstring t])
        in
        let (lcc, lsvs, lels) = extractsegv lhs in
        let (rcc, rsvs, _) = extractsegv rhs in
        let rec renum el =
          match el with
            Element (_, ResUnknown m, t) -> registerElement (Resnum m, t)
          | _ -> el
        in
        let newlhs = registerCollection (lcc, lsvs) in
        let rec newrhs el = registerCollection (rcc, el :: rsvs) in
        let rec newante el = Seq (st, newlhs, newrhs el) in
        let r =
          ((newante <*> renum) <* lels) @ antes,
          Seq (st, newlhs, rhs)
        in
        let showrule =
          pairstring (bracketedliststring seqstring " AND ") seqstring
            " INFER "
        in
        if !thingdebug then
          consolereport
            ["rearrangetoResolve given "; showrule (antes, conseq);
             "; delivers "; showrule r];
        r
    let rec freshRuletoprove (params, provisos, antes, conseq) =
      let (antes, conseq) = numberforproof (antes, conseq) in
      params, provisos, antes, conseq
    let rec freshTheoremtoprove stuff =
      let (params, provisos, _, conseq) = freshRuletoprove stuff in
      params, provisos, conseq
    let rec wehavestructurerule kind stilesopt =
      let names =
        (snd <* ((fun (k, _) -> k = kind) <| !structurerules))
      in
      let rec getstile = fun (Seq (st, _, _)) -> st in
      not (null names) &&
      (match stilesopt with
         None -> true
       | Some (cst :: asts) ->
           List.exists
             (fun name ->
                match compiledthingnamed name with
                  Some
                    (CookedRule
                       (_, (_, (params, provs, tops, bottom)), ax)) ->
                    ((ax || !applyderivedrules) && cst = getstile bottom) &&
                    eqlists (fun (x, y) -> x = y) ((getstile <* tops), asts)
                | _ -> false)
             names
       | _ -> false)
    let rec ftaors fR fThm weakenthms name cxt stuff =
      match compiledthingnamed name with
        Some (CookedRule (_, (vars, toapply), ax)) ->
          let (cxt, env, resnums, r) = fR cxt stuff vars toapply in
          Some (cxt, env, resnums, Rule (r, ax))
      | Some
          (CookedTheorem (_, (vars, (_, _, _, Seq (st, _, _) as toapply)))) ->
          let (cxt, env, resnums, t) =
            fThm
              (weakenthms &&
               wehavestructurerule LeftWeakenRule (Some [st; st]))
              (weakenthms &&
               wehavestructurerule RightWeakenRule (Some [st; st]))
              cxt stuff vars toapply
          in
          Some (cxt, env, resnums, Theorem t)
      | Some (Rawthing th) -> Some (cxt, empty, ([], []), th)
      | None -> None
    let freshThingtoapply = ftaors freshRuletoapply freshTheoremtoapply
    let freshThingtosubst = ftaors freshRuletosubst freshTheoremtosubst
    let rec compiletoprove (pros, antes, conseq) =
      let ((_, (_, pros', antes', conseq')), _) =
        compileR false false
          ([], ((fun p -> true, p) <* pros), antes, conseq)
      in
      let (antes', conseq') = numberforproof (antes', conseq') in
      pros', antes', conseq'
    let rec freshThingtoprove name =
      match compiledthingnamed name with
        Some (CookedRule ((vars, toprove), _, ax)) ->
          Some (Rule (freshRuletoprove toprove, ax))
      | Some (CookedTheorem ((vars, toprove), _)) ->
          Some (Theorem (freshTheoremtoprove toprove))
      | Some (Rawthing th) -> Some th
      | None -> None
    (* givens get weakened if required; they get renumbered for use; otherwise untouched *)
    let rec freshGiven weaken =
      fun (Seq (st, lhs, rhs) as seq) cxt ->
        (* can't help feeling that extend should be a well-known function ... *)
        let rec extend a1 a2 a3 =
          match a1, a2, a3 with
            true, Collection (_, BagClass FormulaClass, es), cxt ->
              let (cxt, vid) =
                freshVID cxt (BagClass FormulaClass) (extraBag ())
              in
              let sv =
                registerSegvar
                  ([], registerUnknown (vid, BagClass FormulaClass))
              in
              cxt, registerCollection (BagClass FormulaClass, sv :: es)
          | _, t, cxt -> cxt, t
        in
        let (cxt, lhs) =
          extend
            (weaken && wehavestructurerule LeftWeakenRule (Some [st; st])) lhs
            cxt
        in
        let (cxt, rhs) =
          extend
            (weaken && wehavestructurerule RightWeakenRule (Some [st; st]))
            rhs cxt
        in
        let rec unknownres =
          function
            Collection (_, cc, els) ->
              registerCollection
                (cc,
                   ((function
                       Element (_, Resnum r, t) ->
                         registerElement (ResUnknown r, t)
                     | el -> el) <*
                    els))
          | t -> t
        in
        (* can't happen *)
        let (interesting_resources, _, _, conseq, cxt) =
          renumberforuse [] [] (Seq (st, unknownres lhs, unknownres rhs)) cxt
        in
        cxt, interesting_resources, conseq
    let rec addstructurerule kind name =
      let fc = FormulaClass in
      let oc = OperatorClass in
      let bc = BagClass FormulaClass in
      let lc = ListClass FormulaClass in
      let rec bag es = registerCollection (bc, es) in
      let rec list es = registerCollection (lc, es) in
      let idB = registerId ("B", fc) in
      let idC = registerId ("C", fc) in
      let B = registerElement (Nonum, idB) in
      let C = registerElement (Nonum, idC) in
      let idX = registerId ("X", bc) in
      let idX' = registerId ("X'", bc) in
      let idY = registerId ("Y", bc) in
      let idY' = registerId ("Y'", bc) in
      let X = registerSegvar ([], idX) in
      let X' = registerSegvar ([], idX') in
      let Y = registerSegvar ([], idY) in
      let Y' = registerSegvar ([], idY') in
      let idL = registerId ("L", lc) in
      let idL' = registerId ("L'", lc) in
      let L = registerSegvar ([], idL) in
      let L' = registerSegvar ([], idL') in
      let idE = registerId ("E", fc) in
      let idF = registerId ("F", fc) in
      let idG = registerId ("G", fc) in
      let star = registerId ("star", oc) in
      let rec uncurried e x f =
        registerElement (Nonum, registerApp (x, registerTup (",", [e; f])))
      in
      let rec curried e x f =
        registerElement (Nonum, registerApp (registerApp (x, e), f))
      in
      let rec ispatvar v =
        member (v, [idB; idC; idX; idX'; idY; idY'; idL; idL'])
      in
      let match__ = matchvars false ispatvar in
      let rec seqmatch =
        fun (Seq (_, phs, pcs)) ->
          fun (Seq (st, hs, cs)) ->
            seqmatchvars false ispatvar (Seq (st, phs, pcs))
              (Seq (st, hs, cs))
      in
      (* this function checks that a rule is exactly as we want it to be, used currently
       * for cut and weakening rules, whose properties we exploit both in appearance 
       * transformations (cut) and in automatic transformations (cut, weakening in 
       * resolution steps -- oh, how I wish we could do that by tactic, so it left
       * the engine). Other checks - 
       * currently on transitivity and reflexivity - are more casual, because those
       * rules only have appearance transformations.  Identity could be more casual as
       * well, I guess, but it works at present so leave it alone.
       * RB 21/v/98
       *)
      (* the descriptions below assume that single-formula sides of sequents
       * are parsed as Lists.
       * It will work provided match rigorously matches structure 
       * (Segvar to Segvar, Element to Element) and doesn't try to 
       * be too clever about what bags mean.
       * Some blah means we must have just these parameters / provisos 
       * (cos we apply the rule automatically sometimes, e.g. cut and weaken); 
       * None means we don't care.
       * Actually I don't think we care about the parameters, ever, but time
       * will tell.
       * RB 31/vii/96.
       *)
      (* the check was failing because of the ismetav check in match. Fixed by
       * parameterising ismetav in match ...
       *)
      let rec matchrule (mparams, mprovs, mtops, mbottom) =
        match compiledthingnamed name with
          Some (CookedRule (_, (_, (params, provs, tops, bottom)), _) as r) ->
            (* take the 'toapply' version, just in case *)
            if !thingdebug then
              begin
                let rec myseqstring =
                  fun (Seq (_, hs, gs)) ->
                    (smltermstring hs ^ " ") ^ smltermstring gs
                in
                consolereport
                  ["checking ";
                   ruledatastring true (params, provs, tops, bottom);
                   " against ";
                   quadruplestring (optionstring termliststring)
                     (optionstring
                        (bracketedliststring provisostring " AND "))
                     (bracketedliststring myseqstring " AND ") myseqstring
                     ", " (mparams, mprovs, mtops, mbottom)]
              end;
            begin try
              match
				(match mparams with
					Some mparams ->
					  optionfold (uncurry2 (uncurry2 match__))
						(mparams ||| ((registerId <*> paramidbits) <* params))
						empty
				  | None -> Some empty)
				&~~
				optionfold (uncurry2 (uncurry2 seqmatch)) ((mtops ||| tops))
				&~~
				seqmatch mbottom bottom
              with
                Some env ->
                  begin match mprovs with
                    Some mprovs ->
                      eqbags (fun (x, y) -> x = y : proviso * proviso -> bool)
                        ((remapproviso env <* mprovs),
                         (snd <* provs))
                  | None -> true
                  end
              | _ -> false
            with
              Zip_ -> false
            end
        | _ -> false
      in
      (match kind with
         CutRule ->
           List.exists matchrule
             [Some [idB], Some [],
              [Seq ("", bag [X], list [B]); Seq ("", bag [X; B], list [C])],
              Seq ("", bag [X], list [C]);
              Some [idB], Some [],
              [Seq ("", bag [X], bag [B; Y]); Seq ("", bag [X; B], bag [Y])],
              Seq ("", bag [X], bag [Y]);
              Some [idB], Some [],
              [Seq ("", bag [X], bag [B; Y]);
               Seq ("", bag [X'; B], bag [Y'])],
              Seq ("", bag [X; X'], bag [Y; Y'])]
       | LeftWeakenRule ->
           List.exists matchrule
             [Some [idB], Some [], [Seq ("", bag [X], list [C])],
              Seq ("", bag [X; B], list [C]);
              Some [idB], Some [], [Seq ("", bag [X], bag [Y])],
              Seq ("", bag [X; B], bag [Y])]
       | RightWeakenRule ->
           List.exists matchrule
             [Some [idB], Some [], [Seq ("", bag [X], bag [Y])],
              Seq ("", bag [X], bag [B; Y])]
       | IdentityRule ->
           List.exists matchrule
             [None, None, [], Seq ("", bag [X; B], list [B]);
              None, None, [], Seq ("", bag [X; B], bag [B; Y]);
              None, None, [], Seq ("", list [L; B; L'], list [B])]
       | TransitiveRule ->
           (* we are looking for something of the form
                FROM X |- E op F AND X |- F op' G INFER X |- E op'' G
              where we don't care what X is, provided it's the same in all three places,
              and we don't care what the ops are. We don't care about parameters, 
              provisos, any of that stuff.  _All that really matters is that 
              E, F and G should be arranged like that - transitively, cuttishly.
              I guess the stiles have to be the same as well.
              RB 21/v/98
            *)
           begin match thingnamed name with
             Some
               (Rule
                  ((_, _, [Seq (a1st, a1l, a1r); Seq (a2st, a2l, a2r)],
                    Seq (cst, cl, cr)), _), _) ->
               (((a1st = a2st && a2st = cst) && eqterms (a1l, a2l)) &&
                eqterms (a2l, cl)) &&
               (match
                  collection2term a1r, collection2term a2r, collection2term cr
                with
                  Some a1, Some a2, Some ct ->
                    begin match
                      explodebinapp a1, explodebinapp a2, explodebinapp ct
                    with
                      Some (a, _, b), Some (c, _, d), Some (e, _, f) ->
                        ((eqterms (a, e) && eqterms (d, f)) &&
                         eqterms (b, c)) &&
                        begin registerRelationpat ct; true end
                    | _ -> false
                    end
                | _ -> false)
           | _ -> false
           end
       | ReflexiveRule ->
           (* we are looking for INFER X |- E * E; as with transitivity we don't care what
            * the lhs is.  I guess the stile should be the same as the transitivity rule, but
            * there's no effective way to check that (memo: make boxdraw do it)
            * RB 21/v/98
            *)
           (* No it doesn't matter what the stile is, cos we only hide reflexivities inside
            * transitivies.  RB 1/vii/98
            *)
           match thingnamed name with
             Some (Rule ((_, _, [], Seq (_, _, cr)), _), _) ->
               begin match collection2term cr with
                 Some c ->
                   begin match explodebinapp c with
                     Some (x, _, y) -> eqterms (x, y)
                   | _ -> false
                   end
               | _ -> false
               end
           | _ -> false) &&
      begin
        erasestructurerule name;
        structurerules := (kind, name) :: !structurerules;
        true
      end
  end

