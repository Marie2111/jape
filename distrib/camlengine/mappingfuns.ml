(* $Id$ *)

module type T =
  sig
    type ('a, 'b) mapping
    (* infixr   9   at
       infixr   8   |->  
       infixr   7   ++
       infixr   7   --
     *)
    val empty : ('a, 'b) mapping
    val ( |-> ) : 'a * 'b -> ('a, 'b) mapping
    val ( ++ ) : ('a, 'b) mapping * ('a, 'b) mapping -> ('a, 'b) mapping
    val ( -- ) : ('a, 'b) mapping * 'a list -> ('a, 'b) mapping
    val at : ('a, 'b) mapping * 'a -> 'b option
    val mapped : ('a * 'a -> bool) -> ('a, 'b) mapping -> 'a -> 'b option
    val lfold : (('a * 'b) * 'c -> 'c) -> 'c -> ('a, 'b) mapping -> 'c
    val remapping :
      ('a * 'b -> 'c * 'd) * ('a, 'b) mapping -> ('c, 'd) mapping
    val formappingpairs : ('a * 'b -> unit) * ('a, 'b) mapping -> unit
    val isempty : ('a, 'b) mapping -> bool
    val dom : ('a, 'b) mapping -> 'a list
    val ran : ('a, 'b) mapping -> 'b list
    val aslist : ('a, 'b) mapping -> ('a * 'b) list
    val rawdom : ('a, 'b) mapping -> 'a list
    val rawran : ('a, 'b) mapping -> 'b list
    val rawaslist : ('a, 'b) mapping -> ('a * 'b) list
    val mkmap : ('a * 'b) list -> ('a, 'b) mapping
    val mappingstring :
      ('a -> string) -> ('b -> string) -> ('a, 'b) mapping -> string
    val catelim_mappingstring :
      ('a -> string list -> string list) ->
        ('b -> string list -> string list) -> string -> ('a, 'b) mapping ->
        string list -> string list
  end
(* $Id$ *)

module M : T =
  struct
    open Miscellaneous.M
    open Listfuns.M

    type ('a, 'b) mapping = ('a * 'b) list

    let empty = []
    let isempty xs = xs=[]
    let rec ( |-> ) (a, b) = [a, b]
    let rec ( ++ ) (m, n) = n @ m
    let rec mapped same mapping a =
      let rec ff =
        function
          [] -> None
        | (x, y) :: mapping -> if same (x, a) then Some y else ff mapping
      in
      ff mapping
    (* -- [x] is the inverse of ++ x |-> : that is, it deletes only the outermost value of x.
     * --[x,x] deletes two, and so on.
     *) 
    let rec ( -- ) =
      function
        [], ys -> []
      | (x, xv) :: ps, ys ->
          if member (x, ys) then
            ( -- ) (ps, listsub (fun (x, y) -> x = y) ys [x])
          else (x, xv) :: ( -- ) (ps, ys)
    let rec at (mapping, a) = mapped (fun (x, y) -> x = y) mapping a
    let rec mem a1 a2 =
      match a1, a2 with
        x, [] -> false
      | x, x' :: xs -> x = x' || mem x xs
    let rec lfold f r m =
      let rec ff a1 a2 a3 =
        match a1, a2, a3 with
          dom, r, [] -> r
        | dom, r, (x, y as pair) :: map ->
            if mem x dom then ff dom r map
            else ff (x :: dom) (f (pair, r)) map
      in
      ff [] r m
    
    let rec remapping (f, mapping) =
      lfold
        (fun (pair, m) -> ( ++ ) (( |-> ) (f pair), m))
        empty mapping
    (* dom now gives its result in reverse insertion order, just like rawdom *)
    let rec aslist (m : ('a * 'b) list) =
      seteq (fun (a, b) (a1, b1) -> a = a1) m
    let rec dom m = List.map (fun (r,_)->r) (aslist m)
    let rec ran m = List.map (fun (_,r)->r) (aslist m)
    let rec rawaslist m = m
    let rec rawdom (m : ('a, 'b) mapping) = List.map (fun (r,_)->r) m
    let rec rawran (m : ('a, 'b) mapping) = List.map (fun (_,r)->r) m
    
    let rec formappingpairs (f, mapping) =
      List.iter (fun d -> f (d, Optionfuns.M.unSOME (at (mapping, d)))) (dom mapping)
    let rec mkmap pairs =
      nj_fold (fun ((a, b), map) -> ( ++ ) (map, ( |-> ) (a, b))) pairs empty
    let rec catelim_mappingstring astring bstring sep mapping ss =
      "<<" ::
        catelim_liststring
          (fun (a, b) ss -> "(" :: astring a ("|->" :: bstring b (")" :: ss)))
          sep (List.rev mapping) (">>" :: ss)
    let rec mappingstring a b =
      catelim2stringfn
        (catelim_mappingstring (stringfn2catelim a) (stringfn2catelim b) "++")
  end
