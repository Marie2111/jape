(*
	$Id$

    This file is part of the jape proof engine, which is part of jape.

    Jape is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Jape is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with jape; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
    (or look at http://www.gnu.org).

*)

(* Quite a lot of this stuff is specific to natural deduction.  Tut tut.
   And the list of things it imports shows how deep its roots go
   into the existing system.  Perhaps another tut.
   RB
 *)
 
 (* Lots of spurious Matchin... exceptions added to catch elusive bugs, but some 
  * conscious use of Bind exception in Assoc functions means that I can't shut the
  * compiler up completely.
  * RB 7/xii/94
  *)

open Applyrule
open Context.Cxt
open Context.Cxtstring
open Displaystate
open Hit
open Japeenv
open Listfuns
open Match
open Name
open Optionfuns
open Paraparam
open Proofstate
open Prooftree.Tree
open Prooftree.Tree.Fmttree
open Proviso
open Rewrite.Funs
open Sequent.Funs
open Sequent.Type
open Sml
open Stringfuns
open Tactic
open Tactictype
open Term.Funs
open Term.Store
open Term.Termstring
open Term.Type
open Thing
open Treeformat.Fmt
open Unify

exception Catastrophe_ = Miscellaneous.Catastrophe_
exception ParseError_  = Miscellaneous.ParseError_
exception Selection_   = Selection.Selection_
exception Verifyproviso_ = Provisofuns.Verifyproviso_
exception Tacastrophe_ = Miscellaneous.Tacastrophe_
         
let rec alterTip =
  function
    Some d -> Interaction.alterTip d
  | None -> raise (Catastrophe_ ["(tacticfuns) alterTip None"])

let rec lookupassoc s =
  match Symbol.lookupassoc s with
    Some (b, Symboltype.LeftAssoc) -> Some (b, true)
  | Some (b, _                    ) -> Some (b, false)
  | None                            -> None

(* sameterms is used by doREPLAY (i.e. ReplayTac).  We want identity, so
why on earth won't identity do?  Well, the answer is that even when
replaying we have to unify ResUnknowns.  But since we do want
identity, we surely can insist that the term mapping comes back the same.
*)
(* we should be using unifyvariousEQ, but because of a fault in the recording of
GIVEN steps, we have to use unifyvarious.
*)
let sameterms = unifyvarious
(* fun sameterms (t1,t2) cxt = 
  if eqalphaterms 
       (rewrite cxt t1, rewrite cxt t2) 
  then Some cxt else None
*)

let rec showProof =
  function
    Some d -> Interaction.showProof d
  | None -> raise (Catastrophe_ ["(tacticfuns) showProof None"])
         
let rec refreshProof =
  function
    Some d -> Interaction.refreshProof d
  | None -> raise (Catastrophe_ ["(tacticfuns) refreshProof None"])
         
let rec askNb m bs = Alert.ask (Alert.defaultseverity bs) m bs 0
let rec askNbc m bs c =
  Alert.askCancel (Alert.defaultseverity bs) m bs c 0

let anyCollectionClass = Idclass.BagClass Idclass.FormulaClass
let askChoice = Alert.askChoice
let applyconjectures = Miscellaneous.applyconjectures
let applyderivedrules = Miscellaneous.applyderivedrules
let atoi = Miscellaneous.atoi
let autoselect = Miscellaneous.autoselect
let checkprovisos = Provisofuns.checkprovisos
let conOperatorClass = Idclass.OperatorClass
let consolereport = Miscellaneous.consolereport
let getReason = Reason.getReason
let lemmacount = Miscellaneous.lemmacount
let lacksProof = Proofstore.lacksProof
let needsProof = Proofstore.needsProof
let prefixtoReason = Reason.prefixtoReason
let selection2Subst = Selection.selection2Subst
let setComment = Alert.setComment <*> implode
let setReason = Reason.setReason
let showAlert =
  Alert.showAlert Alert.defaultseverity_alert <*> implode
let symclass = Symbol.symclass
let subterm2subst = Selection.subterm2subst
let tactic_of_string = Termparse.tactic_of_string
let term_of_string = Termparse.term_of_string
let tickmenuitem = Japeserver.tickmenuitem
let uncurry2 = Miscellaneous.uncurry2
let unknownprefix = Symbol.metachar
let verifyprovisos = Provisofuns.verifyprovisos
let _Oracle = Oracle._Oracle

(*  --------------------------------------------------------------------- *)

let proving = ref (namefrom "")
let selections
  :
  (path * (element * side option) option * element list *
     ((element * side option) * string list) list *
     (element * string list) list * string list)
    option ref =
  ref None
let rec getselectedconclusion () =
  (!selections &~~
     (function
        path, Some (c, _), _, _, _, _ -> Some (path, c)
      | _ -> None))
let rec getselectedhypotheses () =
  (!selections &~~
     (fun (path, _, hs, _, _, _) ->
        if null hs then None else Some (path, hs)))
let tacticresult = ref ""
let tactictracing = ref false
let setReason ss =
  if !tactictracing then consolereport ("setReason -- " :: ss);
  setReason ss
let badunify : (term * term) option ref = ref None
let badmatch : (term * term) option ref = ref None
let badproviso : ((term * term) * proviso) option ref = ref None
exception StopTactic_
let
  (getsidedselectedtext, getunsidedselectedtext, getsingleargsel, getsels,
   getargs)
  =
  let rec getsides el sopt =
    try _The ((element2term el &~~ explodebinapp)) with
      _The_ ->
        raise
          (Catastrophe_
             ["getsides given "; elementstring el; "; ";
              optionstring sidestring sopt])
  and deside ((el, sopt), ss) =
    let ss' =
      match sopt with
        Some s ->
          let (left, opp, right) = getsides el sopt in
          begin match s with
            Left ->
              let revss = List.rev ss in
              List.rev
                (implode [List.hd revss; " "; opp; " "; termstring right] ::
                   List.tl revss)
          | Right ->
              implode [termstring left; " "; opp; " "; List.hd ss] :: List.tl ss
          end
      | None -> ss
    in
    el, ss'
  in
  let rec getsidedselectedtext () =
    match !selections with
      Some (path, _, _, concsels, hypsels, givensels) ->
        Some (path, concsels, hypsels, givensels)
    | None -> None
  (* get the selectedtext as if sides didn't come into it.  The problem is that we may have
     selections on both sides of a formula that has been split into two lines.  Otherwise it's easy.
   *)
  and getunsidedselectedtext () =
    (getsidedselectedtext () &~~
       (fun (path, concsels, hypsels, givensels) ->
          let rec pairup =
            function
              [] -> []
            | [csel] -> [csel]
            | ((_, None), _ as csel) :: csels -> csel :: pairup csels
            | ((el, Some side), ss as csel) :: csels ->
                let rec otherside =
                  function
                    (el', Some side'), _ ->
                      sameresource (el, el') && side <> side'
                  | _ -> false
                in
                let rec join ss ss' =
                  let revss = List.rev ss in
                  let (_, opp, _) = getsides el (Some Left) in
                  List.rev (List.tl revss) @
                    implode [List.hd revss; " "; opp; " "; List.hd ss'] :: List.tl ss'
                in
                if List.exists otherside csels then
                  let (((_, _), ss'), csels') = extract otherside csels in
                  ((el, None),
                   (match side with
                      Left -> join ss ss'
                    | Right -> join ss' ss)) ::
                    pairup csels'
                else csel :: pairup csels
          in
          Some (path, (deside <* pairup concsels), hypsels, givensels)))
  and getsingleargsel () =
    match getsidedselectedtext () with
      Some (_, [_, [_; csel; _]], [], []) -> Some csel
    | Some (_, [], [_, [_; hsel; _]], []) -> Some hsel
    | Some (_, [], [], [_; gsel; _]) -> Some gsel
    | _ -> None
  and getsels =
    function
      x :: y :: zs -> y :: getsels zs
    | _ -> []
  and getargs str =
    match getunsidedselectedtext () with
      Some (_, [], [], []) ->
        setReason [str; " failed: no text selections"]; None
    | None -> setReason [str; " failed: no selections"]; None
    | Some (_, cs, hs, gs) ->
        let rec parseit s =
          try term_of_string s with
            ParseError_ ss ->
              raise
                (ParseError_
                   ("Your text selection \"" :: s ::
                      "\" doesn't parse (" :: ss @
                      [")"]))
        in
        Some
             (parseit <*
              List.concat
                (getsels gs ::
                     ((getsels <*> snd) <* (cs @ hs))))
  in
  getsidedselectedtext, getunsidedselectedtext, getsingleargsel, getsels,
  getargs
let rec selparsefail sel ss =
  "Your text selection doesn't parse (" :: ss @
    [") - you selected \""; sel; "\""]
let rec evalname env arg =
  match at (env, arg) with
    None -> arg
  | Some v ->
      match explodeForExecute v with
        name, [] -> name
      | _ ->
          raise
            (Tacastrophe_
               [namestring arg; " evaluates to "; termstring v;
                " which is not a valid tactic/rule name"])
(* it would be nice to have tactical arguments, n'est ce pas?
 * OK then, here goes ... 
 *)
type evaluatedarg = Argstring of name | Argterm of term
let rec striparg t =
  match term2name t with
    Some n -> Argstring n
  | None -> Argterm t
let rec evalstr2 env arg =
  match at (env, arg) with
    None -> Argstring arg
  | Some t -> striparg t
(* we only extend things which actually are named rules or theorems 
   -- or collections of rules in TheoryAlts which don't yet have enough args ...
 *)
let rec extensibletac env tac =
  match tac with
    TermTac (name, args) ->
      begin match evalstr2 env name with
        Argstring name' ->
          begin match thingnamed name' with
            Some (Rule _, _) -> true
          | Some (Theorem _, _) -> true
          | Some (Tactic (params, TheoryAltTac _), _) as r ->
              List.length args < List.length params
          | _ -> false
          end
      | Argterm t -> false
      end
  | _ -> false
let rec withabletac outer env t =
  match t with
    WithSubstSelTac t ->
      begin match outer with
        WithSubstSelTac _ -> false
      | _ -> withabletac outer env t
      end
  | WithArgSelTac t -> withabletac outer env t
  | WithConcSelTac t -> withabletac outer env t
  | WithHypSelTac t -> withabletac outer env t
  | WithFormSelTac t -> withabletac outer env t
  | WithSelectionsTac t -> withabletac outer env t
  | TermTac _ -> extensibletac env t
  | SubstTac _ -> true
  | _ ->(* I hope *)
     false
let rec quoteterm t =
  registerApp (registerId (vid_of_string "QUOTE", Idclass.ConstantClass), t)
(* and when we extend, we QUOTE the argument to avoid name capture *)
(* this sees through 'withing', but is careful not to do so twice.  It relies on the fact
 * that we evaluate outside-in.
 *)
let rec extendwithselection env tac =
  match getsingleargsel (), tac with
    Some arg, TermTac (name, args) ->
      if extensibletac env tac then
        try TermTac (name, args @ [quoteterm (term_of_string arg)]) with
          ParseError_ ss -> raise (ParseError_ (selparsefail arg ss))
      else tac
  | Some arg, WithSubstSelTac t ->
      WithSubstSelTac (extendwithselection env t)
  | Some arg, WithConcSelTac t ->
      WithConcSelTac (extendwithselection env t)
  | Some arg, WithHypSelTac t -> WithHypSelTac (extendwithselection env t)
  | Some arg, WithFormSelTac t ->
      WithFormSelTac (extendwithselection env t)
  | _ ->(* WithSelectionsTac -- clearly not, it includes WithArgSel
     * WithArgSel -- clearly not
     *)
     tac
(*  --------------------------------------------------------------------- *)

let rec currentlyProving n = !proving = n
let rec nextLemmaName () =
  string_of_int begin incr lemmacount; !lemmacount end
let noticetime = ref true
let triesused_total = ref 0
let timesbeingtried = ref 0
let triesleft = ref 0
let timestotry = ref 200
(* for some reason proof replay breaks if this function is called ... I must find out why. *)
let rec time'sUp () = !noticetime && !triesleft <= 0
let rec askTime'sUp () =
  time'sUp () &&
  (* perhaps things should be arranged so that we display the state of the proof at this point ... *)
  (let tried = !timesbeingtried in
   let bs =
     (string_of_int tried, tried) :: (string_of_int (tried * 2), tried * 2) ::
       (if tried / 2 > 0 then
          [string_of_int (tried / 2), tried / 2; "Stop", 0]
        else ["Stop", 0])
   in
   let n =
     askNb
       (implode
          ["Time ran out after ";
           string_of_int (!triesused_total + !timesbeingtried);
           " steps -- do you want to try more steps?"])
       bs
   in
   n = 0 ||
   begin
     triesused_total := !triesused_total + !timesbeingtried;
     timesbeingtried := n;
     triesleft := n;
     false
   end)
let rec noMoreTime () = decr triesleft; askTime'sUp ()
let rec interruptTactic () = noticetime := true; triesleft := 0
let rec clearReason () = setReason []
let rec explain r =
  ((if time'sUp () then ["[Time ran out] "] else []) @ getReason ()) @
    (if r <> "" then [" [applying "; r; "]"] else [])
exception MatchinTermToParam
(* perhaps spurious *)
let rec _TermToParam =
  function
    Id (_, v, c) -> Ordinaryparam (v, c)
  | Unknown (_, v, c) -> Unknownparam (v, c)
  | _ -> raise MatchinTermToParam
exception MatchinTermToParamTerm
(*spurious *)
let _TermToParamTerm =
  (function
     Ordinaryparam vc -> registerId vc
   | _ -> raise MatchinTermToParamTerm) <*> _TermToParam
let rec make_remark name args =
  let args =
    match args with
      [] -> [""]
    | _ -> (termstring <* args)
  in
  match thingnamed name with
    None -> respace ("EVALUATE" :: parseablenamestring name :: args)
  | Some (Rule _, _) -> namestring name
  | Some (Tactic _, _) -> namestring name
  | Some (Macro _, _) -> namestring name
  | Some (Theorem _, _) -> namestring name
(*  --------------------------------------------------------------------- *)
      
let rec freshenv patterns cxt env =
  let us = nj_fold (uncurry2 (sortedmerge earliervar)) ((termvars <* patterns)) [] in
  let rec f =
    function
      (Unknown (_, v, c) as u), (us, cxt, env) ->
        let (cxt', v') = freshVID cxt c v in
        let uname = _The (term2name u) in
        uname :: us, cxt',
        ( ++ ) (env, ( |-> ) (uname, registerUnknown (v', c)))
    | _, r -> r
  in
  nj_fold f us ([], cxt, env)
(*  --------------------------------------------------------------------- *)
    
let rec getGoalPath =
  function
    Some g -> g
  | None -> raise (Catastrophe_ ["Tactic ran out of goals"])
let rec getTip parent goalopt = findTip parent (getGoalPath goalopt)
let rec getSubtree parent goalopt =
  followPath parent (getGoalPath goalopt)
(*  --------------------------------------------------------------------- *)

(*      PROOF

        This kind of tactic detaches the current goal from the proof
        tree; tries to prove it; and then plugs in the proof if it's
        complete, otherwise fails

*)


let tryresolution = ref true
let rec getcxt = fun (Proofstate {cxt = cxt} as state) -> cxt
let rec getconjecture =
  fun (Proofstate {goal = goal; tree = tree} as state) ->
    let (seq, rewinf, _) =
      Prooftree.Tree.Fmttree.getTip tree (getGoalPath goal)
    in
    seq, rewinf
let rec getapplyinfo name args cxt =
  try
    match freshThingtoapply true name cxt args with
      Some (cxt', env, principals, thing) ->
        cxt', (env, principals, thing)
    | None -> raise (Tacastrophe_ ["Nothing named: "; namestring name])
  with
    Fresh_ ss ->
      raise
        (Tacastrophe_
           ("in applying " :: parseablenamestring name ::
              " to arguments " ::
              bracketedliststring termstring ", " args :: ": " :: ss))
let rec getsubstinfo weaken name argmap cxt =
  try
    match freshThingtosubst weaken name cxt argmap with
      Some (cxt', env, principals, thing) ->
        cxt', (env, principals, thing)
    | None -> raise (Tacastrophe_ ["Nothing named: "; namestring name])
  with
    Fresh_ ss ->
      raise
        (Tacastrophe_
           ("in substituting rule/theorem/tactic " ::
              parseablenamestring name :: " with argmap " ::
              bracketedliststring (pairstring termstring termstring ",")
                ", " argmap ::
              ": " :: ss))
let rec hiddencontexts =
  function
    [] -> false, false
  | _ -> !autoAdditiveLeft, !autoAdditiveRight
let rec expandstuff name (env, principals, thing) =
  fun (Proofstate {givens = givens}) ->
    let params = List.rev (Mappingfuns.rawdom env) in
    (* I hope *)
    let how = Prooftree.Tree.Apply (name, params, false) in
    let (kind, antes, conseq, provisos) =
      match thing with
        Rule ((_, provisos, antes, conseq), ax) ->
          (if ax then "rule" else "derived rule"), antes, conseq, provisos
      | Theorem (_, provisos, conseq) -> "theorem", [], conseq, provisos
      | _ -> raise (Catastrophe_ ["expandstuff "; thingstring thing])
    in
    let hiddenleft = not (null givens) && !autoAdditiveLeft in
    let hiddenright = not (null givens) && !autoAdditiveRight in
    kind, hiddencontexts givens, how, env, principals, antes, conseq,
    provisos
let rec preparestuff2apply stuff =
  let (kind, hiddens, how, env, principals, antes, conseq, provisos) =
    stuff
  in
  let (argmap, provisos', antes', conseq') =
    instantiateRule env provisos antes conseq
  in
  kind, hiddens, how, (snd <* argmap), principals, antes',
  conseq', (mkvisproviso <* provisos')
let (apply, resolve, applyorresolve) =
  let rec makestep stuff state resopt =
    let (kind, hiddens, how, argmap, principals, antes, conseq, provisos)
      =
      stuff
    in
    let _ =
      if !(Applyrule.applydebug) > 0 then
        consolereport
          ["makestep "; step_label how; " ";
           proofstatestring (!(Applyrule.applydebug) > 1) state; " ";
           optionstring (pairstring cxtstring prooftreestring ",") resopt]
    in
    let r =
      match resopt with
        Some (cxt, subtree) -> proofstep cxt subtree state
      | None ->
          prefixtoReason [step_label how; " is not applicable: "]; None
    in
    if !(Applyrule.applydebug) > 0 then
      consolereport
        ["makestep => ";
         optionstring (proofstatestring (!(Applyrule.applydebug) > 1)) r];
    r
  in
  let rec apply
    checker filter taker selhyps selconcs stuff reason cxt state =
    let stuff' = preparestuff2apply stuff in
    makestep stuff' state
      (Applyrule.apply checker filter taker selhyps selconcs stuff' reason
         cxt (getconjecture state))
  and resolve
    checker filter taker selhyps selconcs stuff reason cxt state =
    (* We are actually going to do this with some care. 
     * Is there a cut tactic? Is there left weaken? Can we rearrange the rule?
     *
     * Actually we aren't careful enough -- we ought to ask if there is an 
     * additive cut ...
     *
     * And at present we can always rearrange the rule.
     *)
    let
      (kind, hiddens, how, env, (lefts, rights), antes, conseq, provisos)
      =
      stuff
    in
    let (Seq (cst, _, _)) = conseq in
    let rec fail ss =
      setReason ("Can't apply " :: step_label how :: " because " :: ss);
      None
    in
    let rec check r sts words ok =
      if wehavestructurerule r sts then ok ()
      else if wehavestructurerule r None then
        fail ["there is no "; words; " rule"]
      else fail ["there is no "; words; " rule which fits the conclusion"]
    in
    let how' =
      match how with
        Apply (r, params, false) -> Apply (r, params, true)
      | Given (s, i, false) -> Given (s, i, true)
      | _ ->
          raise
            (Catastrophe_
               ["how in resolve is "; prooftree_stepstring how])
    in
    let (antes', conseq') = rearrangetoResolve antes conseq in
    let rec doit () =
      apply checker filter taker selhyps selconcs
        (kind, hiddens, how', env, ([], rights), antes', conseq',
         provisos)
        reason cxt state
    in
    check CutRule (Some [cst; cst; cst]) "cut"
      (fun _ -> check LeftWeakenRule (Some [cst; cst]) "left weaken" doit)
  and applyorresolve
    checker filter taker selhyps selconcs stuff reason cxt state =
    (apply checker filter taker selhyps selconcs stuff reason cxt state |~~
       (fun _ ->
          let rec good =
            fun (Seq (_, lhs, rhs)) ->
              let elhs = explodeCollection lhs in
              let erhs = explodeCollection rhs in
              let hasstructure =
                List.exists (not <*> isleafelement)
              in
              (not (null elhs) && not (null erhs)) &&
              (hasstructure elhs || hasstructure erhs)
          in
          let
            (kind, hiddens, how, env, principals, antes, conseq, provisos)
            =
            stuff
          in
          if null antes && good conseq then
            resolve checker filter taker selhyps selconcs stuff reason cxt
              state
          else None))
  in
  apply, resolve, applyorresolve
let rec applymethod () = if !tryresolution then applyorresolve else apply
let rec doALERT tryf message m ps copt state =
  let m = message m in
  let ps = ((fun (b, t) -> message b, t) <* ps) in
  match ps, copt with
    [], None -> showAlert [m]; Some state
  | [], Some ct -> showAlert [m]; tryf ct state
  | _, None ->(* not sure we need this one ... *)
     tryf (askNb m ps) state
  | _, Some ct -> tryf (askNbc m ps ct) state
let rec doSUBGOAL path =
  fun (Proofstate {tree = tree} as state) ->
    try
      let tip = followPath tree path in
      if isTip tip then Some (withgoal state (Some path))
      else
        begin
          setReason
            ["That subgoal has been solved (SUBGOAL) ";
             fmtpathstring path];
          None
        end
    with
      _ ->
        setReason ["No such subtree (SUBGOAL) "; fmtpathstring path]; None
let rec doCOMPLETE f =
  fun
    (Proofstate {cxt = cxt; goal = goal; tree = parent; root = root} as
       state) ->
    try
      let seq = getTip parent goal in
      let tree' =
        mkTip cxt (rewriteseq cxt seq) Treeformat.Fmt.neutralformat
      in
      let (wholegoal, wholeproof) =
        makewhole cxt root parent (getGoalPath goal)
      in
      let state' =
        withroot
          (withtree
             (withtarget (withgoal state (Some (rootPath tree'))) None)
              tree')
           (Some (wholeproof, wholegoal))
      in
      match
        try f state' with
          Catastrophe_ ss ->
            raise (Catastrophe_ ("in argument of PROVE: " :: ss))
        | Tacastrophe_ ss ->
            raise (Tacastrophe_ ("in argument of PROVE: " :: ss))
        | StopTactic_ -> raise StopTactic_
        | exn ->
            raise
              (Catastrophe_
                 ["Internal Error ("; Printexc.to_string exn;
                  ") in argument of PROVE"])
      with
        Some (Proofstate {cxt = subcxt; tree = subproof}) ->
          if not (hasTip subproof) || time'sUp () then
            proofstep subcxt subproof state
          else None
      | _ -> None
    with
      Catastrophe_ ss -> raise (Catastrophe_ ("in PROVE: " :: ss))
    | Tacastrophe_ ss -> raise (Tacastrophe_ ("in PROVE: " :: ss))
    | StopTactic_ -> raise StopTactic_
    | exn ->
        raise
          (Catastrophe_
             ["Internal Error ("; Printexc.to_string exn; ") in PROVE"])
let rec parseints mess eval ints =
  try
    match debracket (eval ints) with
      Tup (_, ",", ts) -> (term2int <* ts)
    | t -> [term2int t]
  with
    _ ->
      raise
        (Tacastrophe_
           [mess; " must be a tuple of integers; you gave ";
            termstring ints; " = "; termstring (debracket (eval ints))])
(* With the modern prooftree, LAYOUT is a simple assignment to a tip *)
let rec doLAYOUT layout eval action t =
  fun (Proofstate {tree = tree; goal = goal} as state) ->
    let rec parsefmt fmt =
      let fmt' = eval fmt in
      match debracket fmt' with
        Id (_, v, _) -> string_of_vid v
      | Literal (_, String s) -> s
      | _ ->
          raise
            (Tacastrophe_
               ["format in LAYOUT must be string; you gave ";
                termstring fmt'])
    in
    let rec f l t =
      let fmt =
        layout2format parsefmt (parseints "selection in LAYOUT" eval) l
      in
      match t with
        LayoutTac (t', l') ->
          let (fmt', tac) = f l' t' in treeformatmerge (fmt, fmt'), tac
      | _ -> fmt, t
    in
    let (fmt, tac) = f layout t in
    try
      action tac
        (withtree state (set_prooftree_fmt tree (getGoalPath goal) fmt))
    with
      AlterProof_ ss ->
        raise (Catastrophe_ ("AlterProof_ in LAYOUT: " :: ss))
let rec doWITHCONCSEL try__ =
  match getselectedconclusion (), try__ with
    Some (_, c),
    (matching, checker, ruler, filter, taker, selhyps, selconcs) ->
      matching, checker, ruler, filter, taker, selhyps, c :: selconcs
  | _ -> try__
let rec doWITHHYPSEL try__ =
  match getselectedhypotheses (), try__ with
    Some (_, hs),
    (matching, checker, ruler, filter, taker, selhyps, selconcs) ->
      matching, checker, ruler, filter, taker, hs @ selhyps, selconcs
  | _ -> try__
let rec doMATCH
  (matching, checker, ruler, filter, taker, selhyps, selconcs) =
  true, checker, ruler, (bymatch &~ filter), taker, selhyps,
  selconcs
let rec doSAMEPROVISOS
  (matching, checker, ruler, filter, taker, selhyps, selconcs) =
  matching, checker, ruler, (sameprovisos &~ filter), taker,
  selhyps, selconcs
let rec doSIMPLEAPPLY
  (matching, checker, ruler, filter, taker, selhyps, selconcs) =
  matching, checker, apply, filter, taker, selhyps, selconcs
let rec doAPPLYORRESOLVE
  (matching, checker, ruler, filter, taker, selhyps, selconcs) =
  matching, checker, applyorresolve, filter, taker, selhyps, selconcs
let rec doUNIQUE
  (matching, checker, ruler, filter, taker, selhyps, selconcs) =
  matching, checker, ruler, filter, takeonlyone, selhyps, selconcs
let rec doANY
  (matching, checker, ruler, filter, taker, selhyps, selconcs) =
  matching, checker, ruler, filter, takefirst, selhyps, selconcs
let rec doRESOLVE
  (matching, checker, ruler, filter, taker, selhyps, selconcs) =
  matching, checker, resolve, filter, taker, selhyps, selconcs
(* sameterms is identity (but see newjape.sml);
   apply (no fancy resolution);
   takefirst (because proof recording doesn't identify resources)
*)
let rec doREPLAY
  (matching, checker, ruler, filter, taker, selhyps, selconcs) =
  matching, sameterms, apply, filter, takefirst, selhyps, selconcs
(* semantics: keep applying a tactic till it fails, you run out of time, 
 * or there is nothing more to do in the state.  Catch exceptions and 
 * treat them as failure.
 *)
let rec doDO f state =
  if noMoreTime () then Some state
  else if isproven state then Some state
  else
    match
      try f state with
        _ -> None
    with
      None -> Some state
    | Some state' -> doDO f state'
let rec doREPEAT1 f state =
  match
    try f state with
      _ -> None
  with
    None -> Some state
  | answer -> answer
let rec doSEQ a1 a2 a3 =
  match a1, a2, a3 with
    f, [], st -> Some st
  | f, t :: ts, st -> (f t &~ doSEQ f ts) st
(* insert a cut, run the tactic to the left of the cut, then go back to the original position, if it's still there *)
let rec doCUTIN f =
  fun (Proofstate {tree = tree; goal = goal; cxt = cxt} as state) ->
    (* there must be exactly one cut rule, and we must have autoAdditiveLeft *)
    try
      let rec nocando s =
        raise (Tacastrophe_ ["cannot use CUTIN tactic "; s])
      in
      let cutrule =
        match uniqueCut () with
          Some r -> r
        | None -> nocando "unless there is a unique simple cut rule"
      in
      let _ =
        if !autoAdditiveLeft then ()
        else nocando "unless the logic is stated without left contexts"
      in
      let path = deepest_samehyps tree (getGoalPath goal) in
      let subtree = followPath tree path in
      let (Proofstate {tree = tree'; goal = goal'} as state') =
        prunestate path state
      in
      let tippath = getGoalPath goal' in
      let (Proofstate {tree = tree''; cxt = cxt''} as state'') =
        let (cxt', info) = getapplyinfo cutrule [] cxt in
        match
          apply unifyvarious nofilter takeonlyone [] []
            (expandstuff cutrule info state) (namestring cutrule) cxt'
            (withtree state'
                (set_prooftree_fmt tree' tippath Treeformat.Fmt.neutralformat))
        with
          None -> raise (Catastrophe_ ["cut failed in doCUTIN"])
        | Some res -> res
      in
      let (Seq (_, hs, cs)) = sequent subtree in
      let (leftofcut, rightofcut) =
        subgoalPath tree'' tippath [0], subgoalPath tree'' tippath [1]
      in
      let (Seq (_, _, cs')) = sequent (followPath tree'' leftofcut) in
      let (Seq (_, hs', _)) = sequent (followPath tree'' rightofcut) in
      let cuthypel =
        match
          listsub sameresource (explodeCollection hs')
            (explodeCollection hs)
        with
          [c] -> c
        | _ -> raise (Catastrophe_ ["no cuthypel in doCUTIN"])
      in
      let subtree' = augmenthyps cxt'' subtree [cuthypel] in
      let cutconcel =
        match
          listsub sameresource (explodeCollection cs')
            (explodeCollection cs)
        with
          [c] -> c
        | _ -> raise (Catastrophe_ ["no cutconcel in doCUTIN"])
      in
      let (l, r) =
        let rec bang () =
          raise
            (Catastrophe_
               ["resources ";
                pairstring (smlelementstring termstring)
                  (smlelementstring termstring) "," (cutconcel, cuthypel);
                " in doCUTIN"])
        in
        match cutconcel, cuthypel with
          Element (_, rc, _), Element (_, rh, _) ->
            if not (isProperResnum rc) || not (isProperResnum rh) then
              bang ()
            else
              let (nc, nh) = resnum2int rc, resnum2int rh in
              if (nc = nh || nc = 0) || nh = 0 then
                raise
                  (Catastrophe_
                     ["resnums ";
                      pairstring string_of_int string_of_int "," (nc, nh);
                      " in doCUTIN"])
              else nc, nh
        | _ -> bang ()
      in
      let (_, wholeproof) =
        makewhole cxt'' (Some (tree'', rightofcut)) subtree'
          (rootPath subtree')
      in
      let wholeproof' =
        set_prooftree_cutnav wholeproof tippath (Some (- l, - r))
      in
      (* tippath is now useless *)
      try__ (fun s -> nextGoal false (withgoal s goal))
        (f (withgoal
              (withtree state'' wholeproof')
              (Some
                 (subgoalPath wholeproof' (parentPath wholeproof' path)
                    [- l]))))
    with
      FollowPath_ stuff ->
        showAlert
          ["FollowPath_ in doCUTIN: ";
           pairstring (fun s -> s) (bracketedliststring string_of_int ",")
             ", " stuff];
        None
(**********************************************************************

       Evaluation of built-in judgements

       The tactic EVAL patterns succeeeds on a sequent whose consequent
       matches one of the patterns and for which there is a built-in
       rule which succeeds.

 **********************************************************************)

let rec _CanApply triv name state =
  if triv then []
  else
    try
      let (cxt, (_, _, thing as stuff)) =
        getapplyinfo name [] (getcxt state)
      in
      if needsProof name thing then []
      else
        match
          Applyrule.apply unifyvarious nofilter nofilter [] []
            (preparestuff2apply (expandstuff name stuff state))
            (namestring name) cxt (getconjecture state)
        with
          Some rs -> takethelot rs
        | _ -> []
    with
      _ -> []
(* whatever it means, we can't apply it ... *)

let rec _CanApplyInState a1 a2 a3 =
  match a1, a2, a3 with
    triv, name, (Proofstate {goal = Some gpath} as state) ->
      _CanApply triv name state
  | _, _, _ -> []
let rec autoStep a1 a2 a3 =
  match a1, a2, a3 with
    triv, rulenames, Proofstate {goal = None} -> None
  | triv, rulenames, (state : proofstate) ->
      let rec _Applicable (name, cs) =
        match _CanApplyInState triv name state with
          [] -> cs
        | hypmatches ->
            nj_fold (fun (match__, cs) -> (name, match__) :: cs) hypmatches
              cs
      in
      match nj_fold _Applicable rulenames [] with
        [] -> None
      | cs ->
          let cs = sort (fun (n, _) (n', _) -> nameorder n n') cs in
          let rec showRule (name, (cxt, tree)) =
            namestring name ::
                ((seqstring <*> rewriteseq cxt <*> sequent) <* subtrees tree)
          in
          match
            askChoice
              ("Choose a rule from these applicable rules:",
               (showRule <* cs))
          with
            None -> None
          | Some n ->
              let (name, (cxt, newtree)) = List.nth (cs) (n) in
              proofstep cxt newtree state
let rec forceUnify a1 a2 =
  match a1, a2 with
    t1 :: t2 :: ts, (Proofstate {cxt = cxt} as state) ->
      let rec showit t =
        if t = rewrite cxt t then termstring t
        else
          ((termstring t ^ " (which, because of earlier unifications, is equivalent to ") ^
             termstring (rewrite cxt t)) ^
            ")"
      in
      let rec bad reasons =
        setReason
          ("can't unify " :: showit t1 :: " with " :: showit t2 ::
             reasons);
        None
      in
      badunify := None;
      badmatch := None;
      badproviso := None;
      begin try
        match
            (unifyterms (t1, t2) &~ (fSome <*> verifyprovisos))
            (plususedVIDs (plususedVIDs cxt (termVIDs t1)) (termVIDs t2))
        with
          Some cxt' -> forceUnify (t2 :: ts) (withcxt state cxt')
        | None -> badunify := Some (t1, t2); bad []
      with
        Verifyproviso_ p ->
          badproviso := Some ((t1, t2), p);
          bad [" because proviso "; provisostring p; " is violated"]
      end
  | _, state -> Some state

let rec doDropUnify ts ss =
  fun (Proofstate {cxt = cxt} as state) ->
    let _ =
      if !tactictracing then consolereport ["** start doDropUnify"]
    in
    let rec bad reasons =
      setReason
        ("can't drop " :: bracketedliststring elementstring "," ss ::
           " into " :: bracketedliststring elementstring "," ts ::
           reasons);
      None
    in
    try
      match (optionfold (fun (t, cxt) -> dropunify (t, ss) cxt) ts cxt 
             &~~ (fSome <*> verifyprovisos) &~~ simplifydeferred)
      with
        Some cxt' -> Some (withcxt state cxt')
      | None -> bad []
    with
      Verifyproviso_ p ->
        bad [" because proviso "; provisostring p; " is violated"]

let _FINDdebug = ref false
(* test if some Theorem/Rule defines an operator as associative *)
exception Matchinassociativelawstuff_
let rec binary operator t =
  if !_FINDdebug then
    consolereport
      ["binary ("; smltermstring operator; ") ("; smltermstring t; ")"];
  match explodeApp true t with
    f, [l; r] ->
      if f = operator then l, r else raise Matchinassociativelawstuff_
  | _ -> raise Matchinassociativelawstuff_
let rec fringe operator t =
  if !_FINDdebug then
    consolereport
      ["fringe ("; smltermstring operator; ") ("; smltermstring t; ")"];
  match explodeApp true t with
    (Id _ as f), [] -> [f]
  | (Unknown _ as f), [] -> [f]
  | f, [l; r] ->
      if f = operator then fringe operator l @ fringe operator r
      else raise Matchinassociativelawstuff_
  | _ -> raise Matchinassociativelawstuff_
let eq = registerId (vid_of_string "=", conOperatorClass)
let rec associativelaw operator thing =
  let rec assoc params term =
    try
      let (lhs, rhs) = binary eq term in
      let lf = fringe operator lhs in
      let rf = fringe operator rhs in
      if !_FINDdebug then
        consolereport
          ["assoc "; bracketedliststring paraparamstring ", " params;
           " ("; termstring term; ") => lf=";
           bracketedliststring termstring ", " lf; "; rf=";
           bracketedliststring termstring ", " rf];
      (List.length lf = 3 && lf = rf) && _All (formulageneralisable params) rf
    with
      Matchinassociativelawstuff_ -> false
  in
  let rec ok params seq =
    match seq with
      Seq
        (_, Collection (_, _, []),
         Collection (_, _, [Element (_, _, _C)])) ->
        assoc params _C
    | Seq
        (_, Collection (_, _, [Segvar _]),
         Collection (_, _, [Element (_, _, _C)])) ->
        assoc params _C
    | _ -> false
  in
  if !_FINDdebug then
    consolereport
      ["associativelaw ("; termstring operator; ") ("; thingstring thing;
       ")"];
  match thing with
    Theorem (params, [], seq) -> ok params seq
  | Rule ((params, [], [], seq), _) -> ok params seq
  | _ -> false
let rec applyAnyway thing =
  match thing with
    Rule _ -> !applyderivedrules
  | Theorem _ -> !applyconjectures
  | _ -> false
let rec relevant name =
  match thingnamed name with
    None -> false
  | Some (thing, _) ->
      not (currentlyProving name) &&
      (applyAnyway thing || not (needsProof name thing))
let rec allrelevantthings () =
    (fst <*> _The <*> thingnamed) <* (relevant <| thingnames ())

module Assoccache =
  Cache.F (struct 
             type dom=vid and ran=bool 
             let eval operator =
               if !_FINDdebug then
                 consolereport
                   ["allrelevantthings()=";
                    bracketedliststring parseablenamestring ", " (relevant <| thingnames ())];
               List.exists (associativelaw (registerId (operator, conOperatorClass)))
                           (allrelevantthings ()) 
             let size = 127 
           end)

exception Matchinisassociative
let resetassociativecache = Assoccache.reset
let isassociative =
  function
    Id (_, v, _) -> Assoccache.lookup v
  |            _ -> raise Matchinisassociative

(**********************************************************************)

let rec _LeftFold f ts =
  let rec _Fold a1 a2 =
    match a1, a2 with
      r, [] -> r
    | r, t :: ts -> _Fold (f r t) ts
  in
  match ts with
    [] ->
      registerId
        (vid_of_string "GIVE ME A BREAK! (LEFTFOLD)",
         symclass "GIVE ME A BREAK! (LEFTFOLD)")
  | t :: ts -> _Fold t ts

let rec _RightFold f ts =
  let rec _Fold =
    function
      [t] -> t
    | t :: ts -> f t (_Fold ts)
    | [] ->
        registerId
          (vid_of_string "GIVE ME A BREAK! (RIGHTFOLD)",
           symclass "GIVE ME A BREAK! (RIGHTFOLD)")
  in
  _Fold ts

let rec _MkApp curry f l r =
  if curry then registerApp (registerApp (f, l), r)
  else registerApp (f, registerTup (",", [l; r]))

let rec rator t =
  match debracket t with
    Id _ -> Some t
  | App (_, l, _) -> rator l
  | _ -> None

(* for the moment, everything is left-, right- or non-associative.  I guess this 
 * function will break on non-associative operators, just as it will with associative
 * when we finally implement them.
 * RB 17/xii/96.
 *)

exception MatchinAssocInfo (* spurious *)
   
let rec assocInfo =
  function
    Id (_, c, _) as f ->
      let (curried, lassoc) =
        try _The (lookupassoc (string_of_vid c)) with
          None_ -> raise MatchinAssocInfo
      in
      if !_FINDdebug then
        consolereport
          ["assocInfo ("; smltermstring f; ") = ("; string_of_bool curried;
           ", "; string_of_bool lassoc; ")"];
      curried, (if lassoc then _LeftFold else _RightFold) (_MkApp curried f)
  | _ -> raise MatchinAssocInfo

let rec _AssocFlatten pat t =
  let _ =
    if !_FINDdebug then
      consolereport
        ["_AssocFlatten ("; smltermstring pat; ") ("; smltermstring t; ")"]
  in
  let rec af1 f c =
    if isassociative f then
      let (curry, mkExp) = assocInfo f in
      let rec flatFringe t =
        match explodeApp false t with
          (Id (_, c', _) as g), [t1; t2] ->
            if curry && c = c' then flatFringe t1 @ flatFringe t2 else [t]
        | (Id (_, c', _) as g), [Tup (_, ",", [t1; t2])] ->
            if not curry && c = c' then flatFringe t1 @ flatFringe t2
            else [t]
        | _ -> [t]
      in
      let rec flatApp t1 t2 = mkExp (flatFringe t1 @ flatFringe t2) in
      (* This function will normalise every subformula of which f is the operator.
       * One day this won't be necessary.
       *)
      let rec norm t =
        let rec doapp t =
          match t with
            App _ ->
              begin match explodeApp false t with
                (Id (_, c', _) as g), [t1; t2] ->
                  let t1 = norm t1
                  and t2 = norm t2 in
                  if curry && c = c' then Some (flatApp t1 t2)
                  else Some (registerApp (registerApp (g, t1), t2))
              | (Id (_, c', _) as g), [Tup (_, ",", [t1; t2])] ->
                  let t1 = norm t1
                  and t2 = norm t2 in
                  if not curry && c = c' then Some (flatApp t1 t2)
                  else Some (registerApp (g, registerTup (",", [t1; t2])))
              | _ -> None
              end
          | _ -> None
        in
        mapterm doapp t
      in
      Some (norm t)
    else
      begin
        if !_FINDdebug then
          consolereport
            [termstring f; " isn't recognised as associative"];
        None
      end
  in
  match explodeApp true pat with
    (Id (_, c, _) as f), [_; _] -> af1 f c
  | (Id (_, c, _) as f), [] -> af1 f c
  | _ ->
      if !_FINDdebug then
        consolereport
          [termstring pat;
           " isn't a recognisable operator / application"];
      None

(**********************************************************************)

let rec explainfailure a1 a2 =
  match a1, a2 with
    why, None -> setReason (why ()); None
  | why, some -> some
let rec _UnifyWithExplanation message (s, t) cxt =
  try
    explainfailure
      (fun () ->
         [message; " couldn't unify term ("; termstring s; ") with (";
          termstring t; ")."])
      (
         (
            (unifyterms (s, t) cxt |~~ (fun _ -> unifyterms (t, s) cxt)) &~~
          (fSome <*> verifyprovisos)))
  with
    Verifyproviso_ p ->
      setReason
        [message; " terms ("; termstring s; ") and ("; termstring t;
         ") appeared to unify, but proviso "; provisostring p;
         " was violated."];
      None
type arithKind =
  ArithNumber of int | ArithVariable of (term * bool) | ArithOther
(* Solve deterministic  e3 = e1 opn e2 
                    or  e3 invopn e2 = e1 
                    or  e3 invopn e1 = e2 
                    
   with 
   
   neg as the negation function symbol
   
   _C as the conclusion judgement from which this problem arose (for error reports)
   
   cxt as the current context
   
   opn, invopn: int*int->int where opn=+ => invopn=-, opn=* => invopn=div
*)
let rec _ARITHMETIC =
  fun _C cxt opn invopn (e1 : term) (e2 : term) (e3 : term) (neg : term) ->
    let e1 = debracket e1 in
    let e2 = debracket e2 in
    let e3 = debracket e3 in
    let neg = debracket neg in
    (* the negation function symbol *)
       
           (* Classify an arithmetic term as a number, a (negated?) variable, or something else. *)
    let rec _ArithKind (t : term) : arithKind =
      match t with
        Literal (_, Number i) -> ArithNumber i
      | Unknown (_, _, Idclass.NumberClass) -> ArithVariable (t, false)
      | Unknown (_, _, Idclass.FormulaClass) -> ArithVariable (t, false)
      | Unknown (_, _, Idclass.ConstantClass) -> ArithVariable (t, false)
      | App (_, f, t) ->
          if f = neg then
            match _ArithKind t with
              ArithVariable (t, neg) -> ArithVariable (t, not neg)
            | ArithNumber n -> ArithNumber (- n)
            | _ -> ArithOther
          else ArithOther
      | _ -> ArithOther
    in
    (* Construct a literal term from an integer *)
    let rec mkLit n = registerLiteral (Number n) in
    (* Assign the number n to the logical variable e, negating it first if necessary. *)
    let rec result (e, neg) n =
      let n = if neg then - n else n in
      match
        _UnifyWithExplanation "EVALUATE _ARITHMETIC" (e, mkLit n) cxt
      with
        Some cxt' -> Some ("_ARITHMETIC", cxt')
      | None -> None
    in
    let rec checkresult n1 n2 =
      if n1 = n2 then Some ("_ARITHMETIC", cxt) else None
    in
    match _ArithKind e1, _ArithKind e2, _ArithKind e3 with
      ArithNumber v1, ArithNumber v2, ArithNumber v3 ->
        checkresult v3 (opn (v1, v2))
    | ArithNumber v1, ArithNumber v2, ArithVariable e3 ->
        result e3 (opn (v1, v2))
    | ArithNumber v1, ArithVariable e2, ArithNumber v3 ->
        result e2 (invopn (v3, v1))
    | ArithVariable e1, ArithNumber v2, ArithNumber v3 ->
        result e1 (invopn (v3, v2))
    | _ ->
        (* When there are more variables, a proviso should be introduced.
           Dunno what to do when the result is negative.
        *)
        setReason ["EVALUATE couldn't solve arithmetic "; termstring _C];
        None
(**********************************************************************)

let rec _DECIDE (turnstile : string) (cxt : Context.Cxt.cxt) =
  fun (_HS : term) ->
    fun (_CS : term) (oracle : string) (args : string list) ->
      match _Oracle turnstile cxt _HS _CS oracle args with
        Some cxt' -> Some ("ORACLE " ^ oracle, cxt')
      | None -> None
      
(**********************************************************************)
exception MatchinEvaluate exception MatchinTtoV
(* spurious *)
   
let rec explodeEval =
  fun _C ->
    let (f, es) = explodeApp true _C in
    match f with
      Id (_, v, _) -> string_of_vid v, es
    | Literal (_, String s) -> s, es
    | _ -> "", []
exception MatchinOBJECT
(* spurious *) (* moved out for OCaml *)

let rec _Evaluate cxt seq =
  match rewriteseq cxt seq with
    Seq (turnstile, _HS, Collection (_, _, [Element (_, _, _C)])) ->
      begin match explodeEval _C with
        "ASSOCEQ", [source; target] ->
          let source = debracket source in
          let target = debracket target in
          let rec flat source =
            match source with
              App (_, f, _) ->
                begin match rator f with
                  None -> source
                | Some operator ->
                    if isassociative operator then
                      anyway (_AssocFlatten operator) source
                    else source
                end
            | source -> source
          in
          (* Unification may be overkill, for most
                                 of the expected uses of this, but
                                 at least the thing's complete. *)
          begin match
            _UnifyWithExplanation
              "EVALUATE ASSOCEQ" (flat source, flat target) cxt
          with
            Some cxt' -> Some ("ASSOCEQ", cxt')
          | None -> None
          end
      | "ADD", [e1; e2; e3; e4] ->
          _ARITHMETIC _C cxt (fun (x, y) -> x + y) (fun (x, y) -> x - y) e1 e2 e3 e4
      | "MUL", [e1; e2; e3; e4] ->
          _ARITHMETIC _C cxt (fun (x, y) -> x * y) (fun (x, y) -> x / y) e1 e2 e3 e4
      | "DECIDE", conclusion :: oracle :: args ->
          _DECIDE
             turnstile cxt _HS conclusion (termstring oracle)
             (termstring <* args)
      | _ ->
          setReason
            ["_Evaluate couldn't recognise judgement "; termstring _C];
          None
      end
  | Seq
      (turnstile, _HS,
       (Collection (_, idclass, Element (_, _, _C) :: _CS) as _CONCS)) ->
      begin match explodeEval _C with
        "DECIDEBAG", oracle :: args ->
          _DECIDE
             turnstile cxt _HS (registerCollection (idclass, _CS))
             (termstring oracle) (termstring <* args)
      | _ ->
          setReason
            ["_Evaluate couldn't recognise judgement "; termstring _CONCS];
          None
      end
  | s ->
      setReason ["_Evaluate couldn't recognise sequent "; seqstring s];
      None
(* non-single conclusion *)
let rec doEVAL a1 a2 =
  match a1, a2 with
    args,
    (Proofstate {cxt = cxt; goal = Some goal; tree = tree} as state) ->
      let seq = findTip tree goal in
      if !tactictracing then
        consolereport
          ["doEVAL "; cxtstring cxt; " ("; smlseqstring seq; ")"];
      begin match _Evaluate cxt seq with
        None -> None
      | Some (reason, cxt') ->
          proofstep cxt'
            (mkJoin cxt "EVALUATE" (UnRule ("EVALUATE", [])) []
               Treeformat.Fmt.neutralformat seq [] ([], []))
            state
      end
  | args, _ -> None
(**********************************************************************)

let rec appendsubterms t q =
  match t with
    App (_, l, r) -> r :: l :: q
  | Tup (_, _, ts) -> List.rev ts @ q
  | Fixapp (_, _, ts) -> List.rev ts @ q
  | Binding (_, (bs, ss, us), _, _) -> (List.rev ss @ List.rev us) @ q
  | _ -> q
let rec _FIRSTSUBTERM f t =
  let rec _S a1 a2 =
    match a1, a2 with
      [], [] -> None
    | [], rear -> _S (List.rev rear) []
    | t :: front, rear ->
        match f t with
          None -> _S front (appendsubterms t rear)
        | r -> r
  in
  _S [t] []
let _FOLDdebug = ref false
let rec _Matches goal (name, thing, lhs as rule) =
  if currentlyProving name then None
  else if not (applyAnyway thing) && lacksProof name then None
  else
    begin
      if !_FOLDdebug then
        consolereport
          ["_Matches looking at \""; termstring goal; "\" with pattern \"";
           termstring lhs; "\""];
      _FIRSTSUBTERM
         (fun goal ->
            match match__ false lhs goal Mappingfuns.empty with
              Some _ -> Some (name, thing, goal)
            | None -> None)
         goal
    end
let rootenv = ref empty
(* filth, by Richard *)
   
let rec tranformals formals =
  try
      (_The <*> term2name <*> paramvar) <* formals
  with
    _The_ ->
      raise
        (Catastrophe_
           ["parameter list (";
            liststring (termstring <*> paramvar) "," formals;
            ") isn't all names"])
let rec mkenv params args =
  let formals = tranformals params in
  let rec mkenv' a1 a2 =
    match a1, a2 with
      f :: fs, v :: vs -> ( ++ ) (( |-> ) (f, v), mkenv' fs vs)
    | _, _ -> !rootenv
  in
  (* filth, by Richard *)
  mkenv' formals args
let rec mkenvfrommap params argmap =
  let rec mk ((v, t), e) =
    try ( ++ ) (e, ( |-> ) (_The (term2name v), t)) with
      _The_ ->
        raise (Catastrophe_ ["can't happen mkenvfrommap "; termstring v])
  in
  nj_revfold mk argmap !rootenv
let rec _AQ env term =
  let rec _A =
    function
      App (_, Id (_, v, _), a) -> (if string_of_vid v="QUOTE" then Some (_QU env a) else None)
    | Id _ as v -> at (env, _The (term2name v))
    | Unknown _ as v -> at (env, _The (term2name v))
    | _ -> None
  in
  mapterm _A term
and _QU env term =
  let rec _Q =
    function
      App (_, Id (_, v, _), a) -> (if string_of_vid v="ANTIQUOTE" then Some (_AQ env a) else None)
    | _ -> None
  in
  mapterm _Q term
let rec eval env = _AQ env
let rec evalvt env (v, t) = v, eval env t
(* a service to SubstTac *)
   
   (**********************************************************************)

type conclusions = (name * thing * term) list
let conclusionstore = Hashtbl.create 127

let rec emptyenv () = mkenv [] []

(* I don't quite realise why fresh... is used here.  We might as
   well use the rule itself, surely, since it is only being used as
   a pattern.  Or perhaps I am confused, in which case the use of
   newcxt, and the discarding of the usedVIDs result of freshthing,
   are wrong.  RB 2/9/93 *)
(* with bated breath, I try it without freshRule *)
(* that was years ago.  Must have worked *)
(* now with memofix. RB 11/vii/2002 *)
let rec unfix_ConcsOf _ConcsOf n =
    begin
      if !_FOLDdebug then
        consolereport
          ["_ConcsOf "; namestring n; " (=> ";
           optionstring (thingstring <*> fst)
             (thingnamed n);
           ")"];
      match thingnamed n with
        None ->
          setReason ["Nothing named "; namestring n; " (in _ConcsOf)"]; []
      | Some ((Rule ((_, _, _, Seq (_, _, _CS)), _) as t), _) ->
          begin match _CS with
            Collection (_, _, [Element (_, _, _C)]) -> [n, t, _C]
          | _ -> []
          end
      | Some ((Theorem (_, _, Seq (_, _, _CS)) as t), _) ->
          begin match _CS with
            Collection (_, _, [Element (_, _, _C)]) -> [n, t, _C]
          | _ -> []
          end
      | Some (Tactic (_, spec), _) ->
          _ConclusionsofTactic (emptyenv ()) (spec, [])
      | Some (Macro (_, spec), _) ->
          setReason
            ["Only a macro is named "; namestring n; " (in _ConcsOf)"];
          []
    end
and _ConclusionsofTactic env (spec, l) =
  if !_FOLDdebug then
    consolereport
      ["_ConclusionsofTactic ...";
       pairstring tacticstring
         (bracketedliststring
            (triplestring parseablenamestring thingstring termstring ",")
            ",")
         ", " (spec, l)];
  match spec with
    TermTac (name, _) -> _ConclusionsofthingNamed (evalname env name, l)
  | AltTac ts -> nj_fold (_ConclusionsofTactic env) ts l
  | TheoryAltTac ns ->
      nj_fold (fun (n, l) -> _ConclusionsofthingNamed (evalname env n, l)) ns
        l
  | _ -> setReason ["Bad FOLD/UNFOLD argument"]; l
and _ConcsOf v = Fix.memofix conclusionstore unfix_ConcsOf v
and resetconclusioncache () = Hashtbl.clear conclusionstore
and _ConclusionsofthingNamed (n, l) = let ts = _ConcsOf n in ts @ l

let rec resetcaches () = resetconclusioncache (); resetassociativecache ()

(**********************************************************************)


let _THING = (ref None : term option ref)
let rec _IT () = _The !_THING
let rec strsep t =
  match debracket t with
    Literal (_, String s) -> s
  | _ -> termstring t
let rec listf a1 a2 a3 =
  match a1, a2, a3 with
    [], [], r -> List.rev r
  | [], t :: ts, r -> listf [] ts (" " :: termstring t :: " " :: r)
  | "%" :: "l" :: fs, t :: ts, r ->
      listf fs ts
        ((match debracket t with
            Tup (_, ",", [Tup (_, _, ts); sep]) ->
              liststring termstring (strsep sep) ts
          | Tup (_, ",", [Tup (_, _, ts); sep1; sep2]) ->
              liststring2 termstring (strsep sep1) (strsep sep2) ts
          | _ -> termstring t) ::
           r)
  | "%" :: "s" :: fs, t :: ts, r -> listf fs ts (message t :: r)
  | "%" :: "t" :: fs, t :: ts, r -> listf fs ts (termstring t :: r)
  | "%" :: f :: fs, ts, r -> listf fs ts (f :: r)
  | ["%"], ts, r -> listf [] ts ("%" :: r)
  | f :: fs, ts, r -> listf fs ts (f :: r)
and message term =
  match debracket term with
    Tup (_, ",", Literal (_, String format) :: ts) ->
      implode (listf (explode format) ts [])
  | Literal (_, String s) -> s
  | _ -> termstring term
let message = message

exception MatchindoJAPE_ (* spurious *)
exception BadMatch_ (* moved out for OCaml *)
exception MatchinTtoIL_ (* not spurious, really *) (* moved out for OCaml *)
exception MatchinJAPEparam_ (* moved out for OCaml *)
   
let rec doJAPE tryf display env ts =
  fun
    (Proofstate
       {cxt = cxt;
        goal = goal;
        target = target;
        tree = tree;
        givens = givens;
        root = root} as state) ->
    let adhoceval = rewrite cxt <*> eval env in
    let rec _Tickmenu on menu label state =
      try
        let rec _U s = String.sub (s) (1) (String.length s - 2) in
        let rec _V t =
          match adhoceval t with
            Literal (_, String s) -> _U s
          | Id (_, v, _) -> string_of_vid v
          | _ -> raise MatchindoJAPE_
        in
        tickmenuitem (_V menu, _V label, on); Some state
      with
        BadMatch_ ->
          setReason
            (["Badly-formed JAPE tactic: "] @ (termstring <* ts));
          None
    in
    (* function is Term to Integer List *)
    let rec _TtoIL =
      function
        Literal (_, Number n) -> [n]
      | Tup (_, ",", ts) ->
          ( </ ) ((fun (x, y) -> x @ y), []) ((_TtoIL <* ts))
      | _ -> raise MatchinTtoIL_
    in
    let bang () = 
      setReason ["Badly-formed tactic: JAPE("; liststring termstring "," ts; ")"];
      None
    in
    match ts with
      [] -> bang()
    | t :: _ ->
        match explodeApp true t with
          Id (_,v,_), ts ->
            (match string_of_vid v, ts with
               "write", [t] ->
                 consolereport [message (adhoceval t); "\n"]; Some state
             | "showreason", [] ->
                 showAlert ("Reason is: " :: explain ""); Some state
             | "cachereset", _ ->(*  This should be done automatically when a theory-search button
                                     changes its state (says Bernard); or we should get rid of caches (says Richard)
                                  *)
                resetcaches (); Some state
             | "tick", [menu; label] ->
                 _Tickmenu true menu label state
             | "untick", [menu; label] ->
                 _Tickmenu false menu label state
             | "tactic", [dest; tactic] ->
                 begin try
                   let dest = adhoceval dest in
                   let tactic = adhoceval tactic in
                   let (name, args) = explodeForExecute dest in
                   let rec param =
                     function
                       Id (h, v, c) -> Ordinaryparam (v, c)
                     | _ -> raise MatchinJAPEparam_
                   in
                   let params = (param <* args) in
                   addthing
                     (name, Tactic (params, transTactic tactic), InLimbo);
                   (* cleanup(); (*DO ME SOON*)*)
                   resetcaches ();
                   Some state
                 with
                   MatchinJAPEparam_ ->
                     setReason ["Badly-formed parameters for JAPE(set)"]; None
                 end
             | "GROUND", [t] ->
                 let vs = termvars (adhoceval t) in
                 if List.exists isUnknown vs then None else Some state
             | "UNKNOWN", [t] ->
                 begin match adhoceval t with
                   Unknown _ -> Some state
                 | _ -> None
                 end
             | _ -> bang())
        | _ -> bang()
        
let rec doFLATTEN env f =
  fun (Proofstate {cxt = cxt; goal = goal; tree = tree} as state) ->
    match rewriteseq cxt (getTip tree goal) with
      Seq (st, _HS, Collection (_, collc, [Element (_, resn, _C)])) as
        seq ->
        let f = eval env f in
        begin match _AssocFlatten f _C with
          Some _C' ->
            (* _AssocFlatten should give back rule dependencies
                                                     * that we can attach to UnRule below
                                                     *)
            if _C = _C' then(* eqterms is modulo bracketing, so is not to be used here! *)
             Some state
            else
              proofstep cxt
                (mkJoin cxt "FLATTEN" (UnRule ("FLATTEN", [])) [f]
                   Treeformat.Fmt.neutralformat seq
                   [mkTip cxt
                      (rewriteseq cxt
                         (Seq
                            (st, _HS,
                             registerCollection
                               (collc, [registerElement (resn, _C')]))))
                      Treeformat.Fmt.neutralformat]
                   ([], []))
                state
        | None -> setReason ["Cannot FLATTEN "; termstring f]; None
        end
    | _ -> setReason ["FLATTEN with multiple-conclusion sequent"]; None
(**********************************************************************)
let rec trace argstring name args =
  fun (Proofstate {cxt = cxt; goal = goal; tree = tree} as state) ->
    if !tactictracing then
      consolereport
        [parseablenamestring name; " "; argstring cxt args;
         match goal with
           None -> ""
         | Some path ->
             (" [[" ^
                seqstring
                  (rewriteseq cxt (sequent (followPath tree path)))) ^
               "]]"]
let tracewithargs =
  trace
    (fun cxt -> liststring (argstring <*> rewrite cxt) " ")
let tracewithmap =
  trace
    (fun cxt ->
       bracketedliststring
         (pairstring termstring (termstring <*> rewrite cxt)
            ",")
         ",")
let rec nullcontn s = s
let rec applyBasic
  name (env, _, thing as stuff)
    (matching, checker, ruler, filter, taker, selhyps, selconcs as try__)
    cxt state =
  let reason = make_remark name [] in
  trace
    (fun cxt ->
       Mappingfuns.mappingstring termstring
         (termstring <*> rewrite cxt))
    name env state;
  if currentlyProving name then
    begin
      setReason
        ["But "; parseablenamestring name;
         " is what you're trying to prove!"];
      None
    end
  else if not (applyAnyway thing) && lacksProof name then
    begin setReason [parseablenamestring name; " is unproved"]; None end
  else
    ruler checker filter taker selhyps selconcs
      (expandstuff name stuff state) reason cxt state
(* because this is generic it has to be outside the loop, 
 * and given dispatchTactic as an argument 
 *)
let rec tryApplyOrSubst
  dispatch getit mke con trace display try__ contn name args =
  fun
    (Proofstate
       {cxt = cxt;
        tree = tree;
        givens = givens;
        goal = goal;
        target = target;
        root = root} as state) ->
    if noMoreTime () then Some state
    else
      (* warning: this causes a loop in autoTactics if timesbeingtried=0 *)
      (* if isproven state then Some state else -- removed because it is confusing error-message tactics *)
      let (cxt, stuff) = getit name args cxt in
      match stuff with
        _, _, Tactic (formals, tac) ->
          let rec def tac args =
            trace name args state;
            dispatch display try__ (mke formals args) contn tac state
          in
          begin match args, tac with
            _ :: _, TheoryAltTac ns ->
              def (AltTac ((fun n -> con (n, args)) <* ns)) []
          | _ -> def tac args
          end
      | _, _, Macro (formals, m) ->
          let m' = eval (mke formals args) m in
          let t =
            try transTactic m' with
              ParseError_ ss ->
                raise
                  (Tacastrophe_
                     ((["can't parse expanded macro-tactic ";
                        parseablenamestring name; ": "] @
                         ss) @
                        [".\nExpanded tactic is "; termstring m]))
          in
          dispatch display try__ !rootenv(* so we can ASSIGN ??? *)  contn t state
      | argmap, _, _ ->
          (* must it be a rule? *)
          let rec showit () =
            let (_, wholetree) =
              makewhole cxt root tree (rootPath tree)
            in
            let rec wholepath path =
              match root, path with
                Some (_, rpath), Some (FmtPath pns) ->
                  Some (subgoalPath wholetree rpath pns)
              | _ -> path
            in
            let wholegoal = wholepath goal in
            let wholetarget = wholepath target in
            let _ = (showProof display wholetarget wholegoal cxt wholetree !autoselect 
                    : displaystate) in
            ()
          in
          let rec hideit () = refreshProof display in
          beforeOfferingDo showit;
          failOfferingDo hideit;
          succeedOfferingDo hideit;
          contn (applyBasic name stuff try__ cxt state)
let rec newpath tacstr eval =
  fun (Proofstate {tree = tree} as state) p ->
    let rec simple ns = parseints (" path in " ^ tacstr) eval ns in
    let rec mkpath =
      function
        Parent p -> parentPath tree (mkpath p)
      | LeftSibling p -> siblingPath tree (mkpath p) true
      | RightSibling p -> siblingPath tree (mkpath p) false
      | HypRoot p -> deepest_samehyps tree (mkpath p)
      | Subgoal (p, ns) -> subgoalPath tree (mkpath p) (simple ns)
      | SimplePath ns -> FmtPath (simple ns)
    in
    try mkpath p with
      FollowPath_ (s, ns) ->
        raise
          (Tacastrophe_
             ["bad path in "; tacstr; ": "; s; "; ";
              bracketedliststring string_of_int "," ns])
let rec dispatchTactic display try__ env contn tactic =
  fun (Proofstate {cxt = cxt} as state) ->
    if !tactictracing then
      consolereport ["dispatching "; tacticstring tactic];
    match tactic with
      SkipTac -> contn (Some state)
    | FailTac -> None
    | StopTac -> raise StopTactic_
    | SeqTac ts ->
        contn
          (doSEQ (dispatchTactic display try__ env nullcontn) ts state)
    | AltTac ts ->
        findfirst
          (fun t -> dispatchTactic display try__ env contn t state) ts
    | TheoryAltTac ns ->
        dispatchTactic display try__ env contn
          (AltTac ((fun n -> TermTac (n, [])) <* ns)) state
    | RepTac t ->
        contn (doDO (dispatchTactic display try__ env nullcontn t) state)
    | IfTac t ->
        contn
          (doREPEAT1 (dispatchTactic display try__ env nullcontn t) state)
    | LayoutTac (t, l) ->
        doLAYOUT l (eval env) (dispatchTactic display try__ env contn) t
          state
    | CompTac t ->
        doCOMPLETE (dispatchTactic display try__ env contn t) state
    | EvalTac ts -> contn (doEVAL ts state)
    | FoldHypTac (name, stuff) ->
        doFOLDHYP name display try__ env contn (evalname env name, stuff)
          state
    | UnfoldHypTac (name, stuff) ->
        doUNFOLDHYP name display try__ env contn
          (evalname env name, stuff) state
    | UnfoldTac (name, stuff) ->
        doUNFOLD name display try__ env contn (evalname env name, stuff)
          state
    | FoldTac (name, stuff) ->
        doFOLD name display try__ env contn (evalname env name, stuff)
          state
    | AssignTac spec -> contn (doASSIGN env spec state)
    | UnifyTac terms -> contn (forceUnify ((eval env <* terms)) state)
    | UnifyArgsTac ->
        (getargs "UNIFYARGS" &~~
           (function
              [t] ->
                setReason ["UNIFYARGS failed: only one text selection"];
                None
            | ts -> contn (forceUnify ts state)))
    | AdHocTac ts ->
        contn
          (doJAPE (dispatchTactic display try__ env nullcontn) display env
             ts state)
    | CutinTac t ->
        contn (doCUTIN (dispatchTactic display try__ env contn t) state)
    | BindLHSTac _ ->
        (* deciphering of the binding tactics now occurs in only one place, at the cost
           of stripoption. RB 1/iii/94
         *)
        contn (stripoption (doBIND tactic display try__ env state))
    | BindRHSTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindGoalTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindGoalPathTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindOpenSubGoalTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindOpenSubGoalsTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindConcTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindHypTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindHyp2Tac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindHypsTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindArgTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindArgTextTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindSubstTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindSubstInConcTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindSubstInHypTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindMultiArgTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindFindHypTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindFindConcTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindMatchTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BindOccursTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BadUnifyTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BadMatchTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | BadProvisoTac _ ->
        contn (stripoption (doBIND tactic display try__ env state))
    | AssocFlatTac t -> contn (doFLATTEN env t state)
    | MapTac (name, args) ->
        doMAPTERMS display try__ contn (evalname env name)
          ((eval env <* args)) state
    | TermTac (str, args) ->
        let args' = (eval env <* args) in
        let rec calltac name args =
          if !tactictracing then
            consolereport
              ["(after evaluation dispatching) ";
               tacticstring (TermTac (name, args))];
          tryApply display try__ contn name args state
        in
        let rec trynewtac t =
          dispatchTactic display try__ !rootenv contn t state
        in
        (* no name capture here (but !rootenv so we can ASSIGN ... ??) *)
        let rec newtac t =
          let t' = implodeApp false (t, args') in
          try transTactic t' with
            ParseError_ ss ->
              raise
                (Tacastrophe_
                   (tacticstring tactic :: " evaluates to " ::
                      termstring t' ::
                      ", which isn't a valid tactic, because " :: ss))
        in
        begin match at (env, str) with
          None -> calltac str args'
        | Some t ->
            match args' with
              _ :: _ ->
                (* stick them on and see what it looks like ... *)
                begin match newtac t with
                  TermTac (name, args) -> calltac name args
                | _ ->
                    raise
                      (Tacastrophe_
                         ["argument formula"; termstring t;
                          " applied to additional arguments ";
                          liststring termstring ", " args'; " -- you can't make tactics 'on the fly' that way"])
                end
            | [] ->
                match striparg t with
                  Argstring name ->
                    begin match newtac t with
                      TermTac _ -> calltac name []
                    | t -> trynewtac t
                    end
                | Argterm t' -> trynewtac (newtac t')
        end
    | SubstTac (name, vts) ->
        trySubst display try__ contn (evalname env name)
          ((evalvt env <* vts)) state
    | GivenTac i -> contn (tryGiven display try__ (eval env i) state)
    | WhenTac ts -> contn (doWHEN ts display try__ env state)
    | WithSubstSelTac t ->
        if withabletac tactic env t then
          doWITHSUBSTSEL display try__ state
            (fun try__ -> dispatchTactic display try__ env contn t)
        else dispatchTactic display try__ env contn t state
    | WithArgSelTac t ->
        (* tactics which affect checkers, rulers, filters, takers *)
        (* extendwithselection handles withability *)
        dispatchTactic display try__ env contn (extendwithselection env t)
          state
    | WithConcSelTac t ->
        if withabletac tactic env t then
          dispatchTactic display (doWITHCONCSEL try__) env contn t state
        else dispatchTactic display try__ env contn t state
    | WithHypSelTac t ->
        if withabletac tactic env t then
          dispatchTactic display (doWITHHYPSEL try__) env contn t state
        else dispatchTactic display try__ env contn t state
    | WithFormSelTac t ->
        if withabletac tactic env t then
          dispatchTactic display (doWITHHYPSEL (doWITHCONCSEL try__)) env
            contn t state
        else dispatchTactic display try__ env contn t state
    | WithSelectionsTac t ->
        if withabletac tactic env t then
          dispatchTactic display (doWITHHYPSEL (doWITHCONCSEL try__)) env
            contn (extendwithselection env t) state
        else dispatchTactic display try__ env contn t state
    | MatchTac t ->
        dispatchTactic display (doMATCH try__) env contn t state
    | SameProvisosTac t ->
        dispatchTactic display (doSAMEPROVISOS try__) env contn t state
    | SimpleApplyTac t ->
        dispatchTactic display (doSIMPLEAPPLY try__) env contn t state
    | ApplyOrResolveTac t ->
        dispatchTactic display (doAPPLYORRESOLVE try__) env contn t state
    | UniqueTac t ->
        dispatchTactic display (doUNIQUE try__) env contn t state
    | TakeAnyTac t ->
        dispatchTactic display (doANY try__) env contn t state
    | ResolveTac t ->
        dispatchTactic display (doRESOLVE try__) env contn t state
    | ReplayTac t ->
        let noticetimewas = let r = !noticetime in noticetime := false; r in
        let triesleftwas = !triesleft in
        let r =
          dispatchTactic display (doREPLAY try__) env contn t state
        in
        noticetime := noticetimewas; triesleft := triesleftwas; r
    | ContnTac (t1, t2) ->
        dispatchTactic display try__ env
          (function
             Some s -> dispatchTactic display try__ env contn t2 s
           | None -> None)
          t1 state
    | ExplainTac m ->
        setReason [message (rewrite cxt (eval env m))]; Some state
    | CommentTac m ->
        setComment [message (rewrite cxt (eval env m))]; Some state
    | AlertTac (m, ps, copt) ->
        contn
          (doALERT (dispatchTactic display try__ env nullcontn)
             (message <*> rewrite cxt <*> eval env)
             m ps copt state)
    | NextgoalTac -> contn (Some (nextGoal true state))
    | SetgoalTac p ->
        contn
          (Some
             (withgoal state (Some (newpath "GOALPATH" (eval env) state p))))
(* RULES and THEORY in the paragraph language generate an ALT tactic.  When we
 * apply such a tactic, we want it to behave as much like a RULE or a THEOREM
 * as we can -- it is just a choice between different rules or theorems, 
 * after all.  So we look for such tactics that are applied to arguments,
 * and we copy the arguments to each of their components.  
 * Unfortunately, it means that we need a different kind of ALT, or we can't
 * recognise the things that we want to treat specially.  Oh well.
 * RB 21/i/97
 *)
(* we are going to stop looking things up again and again RB 29/x/97 *)

and tryApply display =
  tryApplyOrSubst dispatchTactic getapplyinfo mkenv
    (fun (n, args) -> TermTac (n, (quoteterm <* args)))(* con *)
     tracewithargs
    display
and trySubst display =
  tryApplyOrSubst dispatchTactic (getsubstinfo true) mkenvfrommap (fun v->SubstTac v)
    tracewithmap display
and tryGiven
  display
    (matching, checker, ruler, filter, taker, selhyps, selconcs as try__)
    i =
  fun (Proofstate {cxt = cxt; givens = givens} as state) ->
    let i =
      try term2int i with
        _ -> raise (Tacastrophe_ ["not an integer"])
    in
    let given =
      try List.nth (givens) (i) with
        Failure "nth" ->
          raise
            (Tacastrophe_
               (if i < 0 then ["negative index"]
                else
                  match List.length givens with
                    0 -> ["no givens available"]
                  | 1 -> ["one given available"]
                  | n -> [string_of_int n; " givens available"]))
    in
    let name = seqstring given in
    (* this is the problem! *)
    let (cxt, principals, given) = freshGiven true given cxt in
    let stuff =
      "given", hiddencontexts givens, Prooftree.Tree.Given (name, i, false),
      Mappingfuns.empty, principals, [], given, []
    in
    ruler checker filter taker selhyps selconcs stuff name cxt state
and doASSIGN env (s, t) state =
  let t' = eval env t in
  let rec fail ss =
    setReason
      ("can't ASSIGN (" :: parseablenamestring s :: "," :: termstring t ::
         ") - " :: ss);
    None
  in
  try Japeenv.set (env, s, t'); resetcaches (); Some state with
    OutOfRange_ range ->
      fail
        ["argument evaluates to "; termstring t'; "; ";
         parseablenamestring s; " can only be set to "; range]
  | NotJapeVar_ -> fail ["it isn't a variable in the environment"]
  | ReadOnly_ -> fail ["that variable can't be altered (at the moment)"]
and doMAPTERMS display try__ contn name args =
  fun (Proofstate {cxt = cxt; goal = goal; tree = tree} as state) ->
    match rewriteseq cxt (getTip tree goal) with
      Seq (_, _HS, Collection (_, _, [Element (_, _, _C)])) ->
        let rec _TryTacOn term =
          tryApply display try__ contn name (args @ [term]) state
        in
        _FIRSTSUBTERM _TryTacOn _C
    | _ -> setReason ["MAPTERMS with multiple-conclusion sequent"]; None
(* this is not the right way to do WithSubst: it ought to take more arguments so that
 * we can build our own pseudo-substitutions.  But a tactic language based on terms
 * is a bit restricted ...
 *)
(* Now it forces you to use the substitution it constructs *)
and doWITHSUBSTSEL display try__ =
  fun (Proofstate {cxt = cxt; goal = goal; tree = tree; givens = givens;
                   target = target; root = root})
    tacfun ->
    match getunsidedselectedtext (), goal with
      Some (path, concsels, hypsels, givensel), Some g ->
        let rec doit ishyp selel selss =
          try
            let (cxt', newel, tree') =
              alterTip display cxt g tree root
                ((ishyp, path, selel), selss)
            in
            let alteredstate =
              Proofstate
                {cxt = cxt'; tree = tree'; givens = givens; goal = goal;
                 target = target; root = root}
            in
            tacfun
              (match try__ with
                 matching, checker, ruler, filter, taker, selhyps,
                 selconcs ->
                   if ishyp then
                     matching, checker, ruler, filter, taker, [newel],
                     selconcs
                   else
                     matching, checker, ruler, filter, taker, selhyps,
                     [newel])
              alteredstate
          with
            Selection_ ss ->
              setReason ("WITHSUBSTSEL failed: " :: ss); None
        in
        begin match concsels, hypsels with
          [cel, css], [] ->(* we ignore givensel *)
           doit false cel css
        | [], [hel, hss] -> doit true hel hss
        | [], [] ->
            setReason
              ["WITHSUBSTSEL applied without a proof text selection"];
            None
        | _ ->
            setReason
              ["WITHSUBSTSEL applied with a multi-formula proof text selection"];
            None
        end
    | None, _ ->
        setReason ["WITHSUBSTSEL applied without any text selection"];
        None
    | _, None ->
        raise (Catastrophe_ ["WITHSUBSTSEL applied without a goal"])
and doUNFOLD name display try__ env contn (tactic, laws) =
  fun (Proofstate {cxt = cxt; goal = goal; tree = tree} as state) ->
    match rewriteseq cxt (getTip tree goal) with
      Seq (_, _HS, Collection (_, collc, [Element (_, resn, _C)])) ->
        let lhss =
          optionfilter
            (fun (name, thing, t) ->
               match explodeApp false t with
                 _, [Tup (_, ",", [l; r])] -> Some (name, thing, l)
               | _ -> None)
            (nj_fold (_ConclusionsofTactic env) laws [])
        in
        findfirst
          ((_Matches _C &~
              (fun (name, _, term) ->
                 if !_FOLDdebug then
                   consolereport
                     ["_Matches found \""; termstring term;
                      "\" - now to try "; parseablenamestring tactic;
                      " and then "; parseablenamestring name];
                 (tryApply display try__ contn tactic [term] &~
                    tryApply display try__ contn name [])
                   state)))
          lhss
    | _ -> setReason ["UNFOLD with multiple-conclusion sequent"]; None
and doFOLD name display try__ env contn (tactic, laws) =
  fun (Proofstate {cxt = cxt; goal = goal; tree = tree} as state) ->
    match rewriteseq cxt (getTip tree goal) with
      Seq (_, _HS, Collection (_, collc, [Element (_, resn, _C)])) ->
        let rhss =
          optionfilter
            (fun (name, thing, t) ->
               match explodeApp false t with
                 _, [Tup (_, ",", [l; r])] -> Some (name, thing, t)
               | _ -> None)
            (nj_fold (_ConclusionsofTactic env) laws [])
        in
        findfirst
          ((_Matches _C &~
              (fun (name, _, term) ->
                 (tryApply display try__ contn tactic [term] &~
                    tryApply display try__ contn name [])
                   state)))
          rhss
    | _ -> setReason ["FOLD with multiple-conclusion sequent"]; None
and doFOLDHYP name display try__ env contn (tactic, patterns) =
  fun (Proofstate {cxt = cxt; goal = goal; tree = tree; givens = givens; 
                   target = target; root = root} as state) ->
    let (_, cxt, env) = freshenv patterns cxt env in
    let patterns = (eval env <* patterns) in
    match rewriteseq cxt (getTip tree goal) with
      Seq (_, _HS, Collection (_, collc, [Element (_, resn, _C)])) ->
        let rec _HypMatches =
          function
            Element (_, _, _Ht) as _H ->
              begin match explodeApp false _Ht with
                _, [Tup (_, ",", [_; rhs])] ->
                  findfirst
                    (fun pat ->
                       match
                         (unifyterms (pat, _Ht) &~ checkprovisos) cxt
                       with
                         None -> None
                       | Some _ ->
                           _FIRSTSUBTERM
                              (fun subterm ->
                                 match
                                     (unifyterms (subterm, rhs) &~
                                      checkprovisos)
                                     cxt
                                 with
                                   Some cxt -> Some (cxt, subterm)
                                 | None -> None)
                              _C)
                    patterns
              | _ -> None
              end
          | _ -> None
        in
        begin match findfirst _HypMatches (explodeCollection _HS) with
          None -> None
        | Some (cxt, term) ->
            tryApply display try__ contn tactic [term]
              (Proofstate
                 {cxt = cxt; goal = goal; target = target; tree = tree;
                  givens = givens; root = root})
        end
    | _ -> setReason ["FOLDHYP with multiple-conclusion sequent"]; None
and doUNFOLDHYP name display try__ env contn (tactic, patterns) =
  fun (Proofstate {cxt = cxt; goal = goal; tree = tree; givens = givens;
                   target = target; root = root} as state) ->
    let (_, cxt, env) = freshenv patterns cxt env in
    let patterns = (eval env <* patterns) in
    match rewriteseq cxt (getTip tree goal) with
      Seq (_, _HS, Collection (_, collc, [Element (_, resn, _C)])) ->
        let rec _HypMatches =
          function
            Element (_, _, _Ht) as _H ->
              begin match explodeApp false _Ht with
                _, [Tup (_, ",", [lhs; _])] ->
                  findfirst
                    (fun pat ->
                       match
                         (unifyterms (pat, _Ht) &~ checkprovisos) cxt
                       with
                         None -> None
                       | Some _ ->
                           _FIRSTSUBTERM
                              (fun subterm ->
                                 match
                                     (unifyterms (subterm, lhs) &~
                                      checkprovisos)
                                     cxt
                                 with
                                   Some cxt -> Some (cxt, subterm)
                                 | None -> None)
                              _C)
                    patterns
              | _ -> None
              end
          | _ -> None
        in
        begin match findfirst _HypMatches (explodeCollection _HS) with
          None -> None
        | Some (cxt, term) ->
            tryApply display try__ contn tactic [term]
              (Proofstate
                 {cxt = cxt; goal = goal; target = target; tree = tree;
                  givens = givens; root = root})
        end
    | _ -> setReason ["UNFOLDHYP with multiple-conclusion sequent"]; None
and doBIND tac display try__ env =
  fun (Proofstate {cxt = cxt; goal = goal; tree = tree} as state) ->
    let matching = fst_of_7 try__ in
    let rec newenv cxt env newformals =
      nj_fold
        (fun (formal, env) ->
           ( ++ )
             (env,
              ( |-> ) (formal, rewrite cxt (_The (at (env, formal))))))
        newformals env
    in
    let rec checkmatching cxt cxt' expr =
      not matching ||
      matchedtarget cxt cxt'
        (nj_fold
           (function
              Unknown (_, u, _), uvs -> u :: uvs
            | _, uvs -> uvs)
           (termvars expr) [])
    in
    let rec bindunify a1 a2 a3 a4 =
      match a1, a2, a3, a4 with
        bad, badp, [], cxt -> Some cxt
      | bad, badp, (_, expr as pe) :: pes, cxt ->
          badunify := None;
          badmatch := None;
          badproviso := None;
          match unifyterms pe cxt with
            None -> badunify := Some pe; bad []
          | Some cxt' ->
              try
                let _ = (verifyprovisos cxt' : cxt) in
                if checkmatching cxt cxt' expr then
                  bindunify bad badp pes cxt'
                else
                  begin
                    badmatch := Some pe;
                    bad [" because the match changed the formula"]
                  end
              with
                Verifyproviso_ p -> badproviso := Some (pe, p); badp p
    in
    let rec bind s cxt env pes =
      let rec bad ss =
        begin match pes with
          [pattern, expr] ->
            setReason
              (s :: " didn't match pattern " :: termstring pattern ::
                 " to formula " :: termstring expr :: ss)
        | _ ->
            setReason
              (s :: " didn't match patterns " ::
                 liststring2 termstring ", " " and "
                   ((fst <* pes)) ::
                 " to formulae " ::
                 liststring2 termstring ", " " and "
                   ((snd <* pes)) ::
                 ss)
        end;
        None
      in
      let (newformals, namecxt, env) =
        freshenv ((fst <* pes)) cxt env
      in
      match
        bindunify bad
          (fun p ->
             bad [" because proviso "; provisostring p; " was violated."])
           ((fun (pattern, expr) -> eval env pattern, expr) <* pes)
          namecxt
      with
        None -> None
      | Some cxt' ->(* Notice that the consequences of the unification do not leak 
         * into the context in which the tactic is evaluated, but the existence of the
         * new identifiers is recorded in namecxt, which is a space leak ...
         * for further matches.
         *)
         Some (namecxt, newenv cxt' env newformals)
    in
    let rec bindThenDispatch s cxt env pes tac =
      (bind s cxt env pes &~~
         (fun (cxt', env') ->
            Some
              (dispatchTactic display try__ env' nullcontn tac
                 (withcxt state cxt'))))
    in
    (*
          fun matchterms pattern value cxt =
          let fun VtoT vmap = 
                Mappingfuns.remapping
                  ((fn (i, t) => (Unknown(_,i,symclass i), t)), vmap)
              fun TtoV tmap = 
                Mappingfuns.remapping
                  ((fn (Unknown(_,i,_), t) => (i, t) | _ => raise MatchinTtoV), 
                   tmap
                  )
          in
              case match (pattern) value (VtoT (varmap cxt)) of
                   Some tmap => Some(cxt withvarmap (TtoV tmap))
              |    None      => None
          end
    *)

    let rec checkBIND s (cxt, env, selectionopt, (pattern, tac)) =
      match selectionopt with
        None -> setReason ["no selection for "; s]; None
      | Some expr -> bindThenDispatch s cxt env [pattern, expr] tac
    in
    let rec doublesel spec ishyp s =
      let rec doit ss =
        try
          let (cxt, t) = selection2Subst true ss cxt in
          checkBIND s (cxt, env, Some t, spec)
        with
          Selection_ ss -> setReason (s :: " failed: " :: ss); None
      in
      match getunsidedselectedtext (), ishyp with
        Some (_, [_, css], _, _), false -> doit css
      | Some (_, [], _, _), false ->
          setReason [s; " failed -- no selected conclusion text"]; None
      | Some (_, _, _, _), false ->
          setReason [s; " failed -- too much selected conclusion text"];
          None
      | Some (_, _, [_, hss], _), true -> doit hss
      | Some (_, _, [], _), true ->
          setReason [s; " failed -- no selected hypothesis text"]; None
      | Some (_, _, _, _), true ->
          setReason [s; " failed -- too much selected hypothesis text"];
          None
      | None, _ -> setReason [s; " failed -- no selected text"]; None
    in
    let rec findsel spec ishyptactic tacname =
      let rec doit selpath selel ss =
        match ss with
          [b; middle; a] ->
            let newtext = (((b ^ "(") ^ middle) ^ ")") ^ a in
            let oldtext = (b ^ middle) ^ a in
            let rec pe ss =
              raise
                (ParseError_
                   ([tacname; ": the term ("; newtext;
                     ") can't be parsed."] @
                      ss))
            in
            let midterm =
              try term_of_string middle with
                ParseError_ ss -> pe ss
            in
            let newterm =
              try term_of_string newtext with
                ParseError_ ss -> pe ss
            in
            let oldterm =
              try term_of_string ((b ^ middle) ^ a) with
                ParseError_ ss ->
                  raise
                    (Catastrophe_
                       ([tacname; " -- can't parse original term ";
                         oldtext; " -- "] @
                          ss))
            in
            if eqterms (oldterm, newterm) then(* Succeed, but don't change the state *)
             Some (Some state)
            else
              checkBIND tacname
                (cxt, env, Some (registerTup (",", [oldterm; newterm])),
                 spec)
        | _ ->
            setReason
              [tacname; ": there should be just a single selection"];
            None
      in
      match getunsidedselectedtext (), ishyptactic with
        Some (path, [cel, css], [], _), false -> doit path cel css
      | Some (path, [cel, css], [], _), true ->
          setReason [tacname; ": selection was made in a conclusion"];
          None
      | Some (path, [], [hel, hss], _), true -> doit path hel hss
      | Some (path, [], [hel, hss], _), false ->
          setReason [tacname; ": selection was made in a hypothesis"];
          None
      | _ ->
          setReason
            [tacname; ": requires selection in exactly one formula"];
          None
    in
    let rec bindOccurs (pat1, term, pat2, tac) =
      let expr = eval env term in
      let (newformals, cxt, env) = freshenv [pat1] cxt env in
      let rec unify (pat, expr) =
        bindunify (fun _ -> None) (fun _ -> None) [pat, expr]
      in
      match subterm2subst unify cxt (eval env pat1) expr with
        None ->
          setReason
            ["LETOCCURS failed to find pattern"; termstring pat1; " in ";
             termstring expr];
          None
      | Some (cxt', subst) ->
          let env = newenv cxt' env newformals in
          (* again, no leakage of context *)
          (* showAlert["bindOccurs got intermediate ", termstring subst]; *)
          bindThenDispatch "LETOCCURS" cxt env [pat2, subst] tac
    in
    let rec seqside2term colln =
      try
        let ts =
            ((_The <*> element2term) <*
             explodeCollection colln)
        in
        (* I wish I didn't have to know how termparse does it, but I do ... *)
        match ts with
          [t] -> t
        | _ ->(* If I don't write this I can never match a single-term lhs/rhs *)
           enbracket (registerTup (",", ts))
      with
        _ -> colln
    in
    (* take it as it is! *)

    let rec opensubgoals () =
      let tiprhss =
           (pathPrefix tree (getGoalPath goal) <*> fst) <|
           allTipConcs tree
      in
      (* the tips relevant to us, with their paths *)
      let tipterms =
          ((fun (path, rhss) ->
              path,
              (_The <* (opt2bool <| (element2term <* rhss)))) <*
           tiprhss)
      in
      List.concat
           ((fun (path, terms) -> ((fun term -> path, term) <* terms)) <*
            tipterms)
    in
    (* it would be nice to be able to check if two values match, but I don't know how to do it without using antiquoting, and
     * that way lies name capture madness.
     * RB 22/viii/00
     *)
    if !tactictracing then
      consolereport ["doBIND dispatching "; tacticstring tac];
    match tac with
      BindConcTac spec ->
        let topt =
          (getselectedconclusion () &~~
             (function
                _, Element (_, _, t) -> Some t
              | _ -> None))
        in
        checkBIND "LETCONC" (cxt, env, topt, spec)
    | BindHypTac spec ->
        begin match getselectedhypotheses () with
          Some (_, [Element (_, _, h)]) ->
            checkBIND "LETHYP" (cxt, env, Some h, spec)
        | _ ->
            setReason ["LETHYP with not exactly one selected hypothesis"];
            None
        end
    | BindHyp2Tac (pat1, pat2, tac) ->
        begin match getselectedhypotheses () with
          Some (_, [Element (_, _, h1); Element (_, _, h2)]) ->
              (
                 (bind "LETHYP2" cxt env [pat1, h1; pat2, h2] |~~
                  (fun _ -> bind "LETHYP2" cxt env [pat1, h2; pat2, h1])) &~~
               (fun (cxt', env') ->
                  bindThenDispatch "LETHYP2" cxt' env' [] tac))
        | _ ->
            setReason
              ["LETHYP2 with not exactly two selected hypotheses"];
            None
        end
    | BindHypsTac spec ->
        begin match getselectedhypotheses () with
          Some (_, (_ :: _ as hs)) ->
            checkBIND "LETHYPS"
              (cxt, env,
               Some
                 (registerTup
                    (",",
                       (((rewrite cxt <*> _The) <*> element2term) <*
                        hs))),
               spec)
        | _ -> setReason ["LETHYPS with no selected hypothesis/es"]; None
        end
    | BindArgTac spec ->
        begin match getsingleargsel () with
          Some sel ->
            begin try
              checkBIND "LETARGSEL"
                (cxt, env, Some (term_of_string sel), spec)
            with
              ParseError_ ss -> setReason (selparsefail sel ss); None
            end
        | None -> None
        end
    | BindSubstTac spec ->
        let rec doit ss =
          try
            let (cxt, t) = selection2Subst true ss cxt in
            checkBIND "LETSUBSTSEL" (cxt, env, Some t, spec)
          with
            Selection_ ss ->
              setReason ("LETSUBSTSEL failed: " :: ss); None
        in
        begin match getunsidedselectedtext () with
          Some (_, [_, css], [], _) -> doit css
        | Some (_, [], [_, hss], _) -> doit hss
        | Some (_, [], [], _) ->
            setReason ["LETSUBSTSEL failed: no proof text selections"];
            None
        | Some (_, _, _, _) ->
            setReason
              ["LETSUBSTSEL failed: too many proof text selections"];
            None
        | None -> setReason ["LETSUBSTSEL failed: no selections"]; None
        end
    | BindMatchTac (pat, term, tac) ->
        bindThenDispatch "LETMATCH" cxt env [pat, eval env term] tac
    | BindOccursTac spec -> bindOccurs spec
    | BindSubstInHypTac spec -> doublesel spec true "LETHYPSUBSTSEL"
    | BindSubstInConcTac spec -> doublesel spec false "LETCONCSUBSTSEL"
    | BindFindHypTac spec -> findsel spec true "LETHYPFIND"
    | BindFindConcTac spec -> findsel spec false "LETCONCFIND"
    | BindMultiArgTac spec ->
        (getargs "LETMULTIARG" &~~
           (function
              [t] ->
                setReason ["LETMULTIARG failed: only one text selection"];
                None
            | ts ->
                checkBIND "LETMULTIARG"
                  (cxt, env, Some (registerTup (",", ts)), spec)))
    | BindLHSTac spec ->
        (* LETLHS/RHS don't insist on a tip, nor a single element *)
        begin match
          rewriteseq cxt (sequent (followPath tree (getGoalPath goal)))
        with
          Seq (_, hs, _) ->
            checkBIND "LETLHS" (cxt, env, Some (seqside2term hs), spec)
        end
    | BindRHSTac spec ->
        (* LETLHS/RHS don't insist on a tip, nor a single element *)
        begin match
          rewriteseq cxt (sequent (followPath tree (getGoalPath goal)))
        with
          Seq (_, _, cs) ->
            checkBIND "LETRHS" (cxt, env, Some (seqside2term cs), spec)
        end
    | BindGoalTac spec ->
        (* LETGOAL does insist on a tip, and a single term as conclusion *)
        begin match
          try Some (rewriteseq cxt (getTip tree goal)) with
            findTip_ -> None
        with
          Some
            (Seq
               (_, _HS, Collection (_, collc, [Element (_, resn, _C)]))) ->
            checkBIND "LETGOAL" (cxt, env, Some _C, spec)
        | Some _ -> setReason ["LETGOAL with non-single conclusion"]; None
        | None -> setReason ["LETGOAL at non-tip position"]; None
        end
    | BindOpenSubGoalTac (name, pat, tac) ->
        (* singular form *)
        begin match opensubgoals () with
          [FmtPath ns, conc] ->
            checkBIND "LETOPENSUBGOAL"
              (cxt,
               ( ++ )
                 (env,
                  ( |-> ) (name, registerTup (",", (int2term <* ns)))),
               Some (rewrite cxt conc), (pat, tac))
        | [] ->
            setReason ["LETOPENSUBGOAL with no unproved conclusions"];
            None
        | _ ->
            setReason
              ["LETOPENSUBGOAL with more than one unproved conclusion"];
            None
        end
    | BindOpenSubGoalsTac spec ->
        (* plural form *)
        begin match opensubgoals () with
          [] ->
            setReason ["LETOPENSUBGOALS with no unproved conclusions"];
            None
        | [_] ->
            setReason
              ["LETOPENSUBGOALS with only one unproved conclusion"];
            None
        | tips ->
            checkBIND "LETOPENSUBGOALS"
              (cxt, env,
               Some
                 (registerTup
                    (",",
                       ((rewrite cxt <*> snd) <*
                        tips))),
               spec)
        end
    | BindArgTextTac (name, tac) ->
        (* these aren't the same sort of binder *)
        begin match getsingleargsel () with
          Some sel ->
            Some
              (dispatchTactic display try__
                 (( ++ )
                    (env, ( |-> ) (name, registerLiteral (String sel))))
                 nullcontn tac state)
        | None -> None
        end
    | BindGoalPathTac (name, tac) ->
        let (FmtPath ns) = getGoalPath goal in
        Some
          (dispatchTactic display try__
             (( ++ )
                (env,
                 ( |-> ) (name, registerTup (",", (int2term <* ns)))))
             nullcontn tac state)
    | BadUnifyTac (n1, n2, tac) ->
        (!badunify &~~
           (fun (t1, t2) ->
              Some
                (dispatchTactic display try__
                   (( ++ )
                      (env, ( ++ ) (( |-> ) (n1, t1), ( |-> ) (n2, t2))))
                   nullcontn tac state)))
    | BadMatchTac (n1, n2, tac) ->
        (!badmatch &~~
           (fun (t1, t2) ->
              Some
                (dispatchTactic display try__
                   (( ++ )
                      (env, ( ++ ) (( |-> ) (n1, t1), ( |-> ) (n2, t2))))
                   nullcontn tac state)))
    | BadProvisoTac (n1, n2, n3, tac) ->
        (!badproviso &~~
           (fun ((t1, t2), p) ->
              Some
                (dispatchTactic display try__
                   (( ++ )
                      (env,
                       ( ++ )
                         (( |-> ) (n1, t1),
                          ( ++ )
                            (( |-> ) (n2, t2),
                             ( |-> )
                               (n3,
                                registerLiteral
                                  (String (provisostring p)))))))
                   nullcontn tac state)))
    | t ->
        raise
          (Catastrophe_
             ["(doBind in tacticfuns) WHEN tactic with non-guard arm ";
              tacticstring t])
and doWHEN ts display try__ env state =
  let rec _W =
    function
      [] -> None
    | [t] -> dispatchTactic display try__ env nullcontn t state
    | t :: ts ->
        match doBIND t display try__ env state with
          None -> _W ts
        | Some x -> x
  in
  _W ts
(* on rules and theorems only, auto-include arguments *)
let rec firstextend env tac =
  if extensibletac env tac then WithSelectionsTac tac else tac
let rec runTactic display env try__ tac =
  fun (Proofstate {goal = goal} as state) ->
    noticetime := true;
    triesleft := !timestotry;
    timesbeingtried := !timestotry;
    triesused_total := 0;
    setComment [];
    clearReason ();
    rootenv := env;
    (* filth, by Richard *)
    match goal with
      None -> None
    | Some goal -> dispatchTactic display try__ env nullcontn tac state
let rec applyTactic display env tac state =
  runTactic display env
    (false, unifyvarious, applymethod (), nofilter, offerChoice, [], [])
    (firstextend env tac) state
let rec applyLiteralTac display env try__ text state =
  runTactic display env try__
    (firstextend env (transTactic (tactic_of_string text))) state

(******** the interface to the outside world ************)

let rec errorcatcher f mess text state =
  try
    match f state with
      None -> showAlert (explain (text ())); None
    | res -> if time'sUp () then showAlert (explain (text ())); res
  with
    Tacastrophe_ ss ->
      showAlert ("Error in tactic: " :: ss @ [" "; mess ()]); None
  | Catastrophe_ ss -> raise (Catastrophe_ (ss @ [" "; mess ()]))
  | ParseError_ ss ->
      showAlert ("Parse error: " :: ss @ [" "; mess ()]); None
  | AlterProof_ ss ->
      showAlert ("AlterProof_ error: " :: ss @ [" "; mess ()]); None
  | StopTactic_ -> None
  | exn -> raise exn
(* in case compiler thinks StopTactic_ is a variable ... *)
     
let rec applyLiteralTactic display env text state =
  errorcatcher
    (applyLiteralTac display env
       (false, unifyvarious, applymethod (), nofilter, offerChoice, [], [])
       text)
    (fun () -> "during tactic " ^ text) (fun () -> text) state
(* CAUTION - as written (by me) autoTactics can clearly be exponential.
 * Don't put too much stuff through it.
 * RB.
 *)
(* this damn thing sometimes switched goals on us ... not any more. RB 21/xii/99 *)
let rec autoTactics display env rules =
  fun (Proofstate {tree = tree; goal = oldgoal} as state) ->
    let rec tryone matching tac goal =
      fun
        (Proofstate {cxt = cxt; tree = tree; givens = givens; root = root}
           as state) ->
        let rec bad ss =
          showAlert (ss @ [" during autoTactics "; tacticstring tac]);
          None
        in
        try
          match
            runTactic display env
              (matching, unifyvarious, apply,
               (if matching then (bymatch &~ sameprovisos)
                else nofilter),
               takefirst, [], [])
              tac
              (Proofstate
                 {cxt = cxt; tree = tree; givens = givens; root = root;
                  goal = Some goal; target = Some goal})
          with
            None -> None
          | Some state' -> if time'sUp () then None else Some state'
        with
          Catastrophe_ ss -> bad ("Catastrophic error: " :: ss)
        | Tacastrophe_ ss -> bad ("Error in tactic: " :: ss)
        | ParseError_ ss -> bad ("Parse error: " :: ss)
        | AlterProof_ ss -> bad ("AlterProof_ error: " :: ss)
        | StopTactic_ -> None
    in
    match
      nj_fold
        (fun ((matching, tac), stateopt) ->
           nj_fold
             (function
                goal, Some state' ->
                  (tryone matching tac goal state' |~~
                     (fun _ -> Some state'))
              | goal, None -> tryone matching tac goal state)
             (allTipPaths
                (match stateopt with
                   Some (Proofstate {tree = tree'}) -> tree'
                 | None -> tree))
             stateopt)
        rules None
    with
      Some (Proofstate {tree = tree'} as state') ->
        autoTactics display env rules
          (nextGoal false (withgoal state' oldgoal))
    | None ->(* round again *)
       state
