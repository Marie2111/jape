(* $Id$ *)

module type T =
  sig
    type term
    val bindingstructure :
      term ->
        ((term list * term list * term list) * (term * (int * int)) list *
           term)
          option
    val addbindingdirective : term list * term list * term list * term -> unit
    val clearbindingdirectives : unit -> unit
    val bindingdebug : bool ref
  end
(* $Id$ *)

module M
  (AAA :
    sig
      module Mappingfuns : Mappingfuns.T
      module Match : Match.T
             with type ('a,'b) mapping = ('a,'b) Mappingfuns.mapping
      
      val bracketedliststring : ('a -> string) -> string -> 'a list -> string
      val consolereport : string list -> unit
      val findfirst : ('a -> 'b option) -> 'a list -> 'b option
      val _MAP : ('a -> 'b) * 'a list -> 'b list
      val quadruplestring :
        ('a -> string) -> ('b -> string) -> ('c -> string) ->
          ('d -> string) -> string -> 'a * 'b * 'c * 'd -> string
      val unSOME : 'a option -> 'a
      val termstring : Match.term -> string
      val termliststring : Match.term list -> string
      val termkind : Match.term -> int
      val termkindmax : int
      (* termkind is term -> 0..termkindmax *)
       
      exception ParseError_ of string list
      
    end)
  : T =
  struct
    open AAA
    open Mappingfuns 
    open Match
    
    type term = Match.term
    
    let bindingdebug = ref false
    type bindingdirective = term list * term list * term list * term
    let bindingdirectives =
      Array.make (termkindmax + 1) ([] : bindingdirective list)
    let badbindings = Array.make (termkindmax + 1) ([] : term list)
    let rec findbadbinding t bbs =
      findfirst (fun bb -> match__ false bb t empty) bbs
    let rec addbindingdirective (bs, ss, us, pat as directive) =
      let k = termkind pat in
      let bds = Array.get bindingdirectives k in
      let bbs = Array.get badbindings k in
      (* test could be refined, but works for multiple re-loads of same syntax *)
      if List.exists (fun bd -> bd = directive) bds then ()
      else
        begin
          Array.set bindingdirectives k (directive :: bds);
          begin match findbadbinding pat bbs with
            None -> Array.set badbindings k (pat :: bbs)
          | Some _ -> ()
          end;
          if !bindingdebug then
            let bt = termliststring in
            let qt = quadruplestring bt bt bt termstring "," in
            consolereport
              ["bindings type "; string_of_int k; " are now ";
               bracketedliststring qt "; " (Array.get bindingdirectives k);
               "; and bad bindings type "; string_of_int k; " are ";
               bt (Array.get badbindings k)]
        end
    let rec clearbindingdirectives () =
      let rec mklist n = if n >= 0 then n :: mklist (n - 1) else [] in
      List.iter
        (fun i ->
           Array.set bindingdirectives i [];
           Array.set badbindings i [])
        (mklist termkindmax)
    let bindingstructure =
      let rec lookup env x = unSOME (at (env, x))
      and matchterm term (bounds, scopes, unscopes, pat) =
        match match__ false pat term empty with
          None -> None
        | Some mapping ->
            let rec fornth a1 a2 a3 =
              match a1, a2, a3 with
                k, i, v :: vs -> (v, (k, i)) :: fornth k (i + 1) vs
              | k, i, [] -> []
            in
            let env =
              (fornth 1 0 bounds @ fornth 2 0 scopes) @ fornth 3 0 unscopes
            in
            let _E = lookup mapping in
            Some
              ((_MAP (_E, bounds), _MAP (_E, scopes), _MAP (_E, unscopes)), env,
               pat)
      in
      let rec bindingstructure t =
        let k = termkind t in
        match findfirst (matchterm t) (Array.get bindingdirectives k) with
          None ->
            begin match findbadbinding t (Array.get badbindings k) with
              Some _ ->
                raise
                  (ParseError_
                     [termstring t;
                      " is almost a binding structure, but not quite"])
            | None -> None
            end
        | res -> res
      in
      bindingstructure
  end
