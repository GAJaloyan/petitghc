(* abstract syntax of the types *)
type typ = Tbool 
         | Tchar 
         | Tinteger
         | TIO
         | Tvar of tvar
         | Tarrow of typ * typ
         | TList of typ
and tvar =
    { id : int;
      mutable def : typ option }

(* module that encapsulates types variables and provides a function to 
 * compare them *)
module V = struct
    type t = tvar
    let compare v1 v2 = Pervasives.compare v1.id v2.id
    let equal v1 v2 = v1.id = v2.id
    let create = let r = ref 0 in fun () -> incr r; { id = !r; def = None }
end

(* head : typ -> typ
 * normalizes a type in head: head t returns a type equal to t
 * that isn't of the form Tvar {def = Some _}, i.e head t follows 
 * the definitions of the type variables at the head of t, as long 
 * as there are some. *)
let rec head = function
| Tvar {def = Some t} -> head t
| x                   -> x

(* canon : typ -> typ
 * normalizes a type entirely, i.e applies head in depth *)
let rec canon z = match (head z) with
| Tarrow (x,y)   -> Tarrow (canon x, canon y)
| Tproduct (x,y) -> Tproduct (canon x, canon y)
| TList x        -> TList (canon x)
| x              -> x

exception UnificationFailure of typ * typ

let unifaction_error t1 t2 = raise (UnificationFailure
    (canon t1, canon t2))

(* occur : tvar -> typ -> bool
 * checks the occurence of a type variable inside a type, we can
 * suppose the variable is undefined *)
let rec occur var t =
    match (head t) with
    | Tarrow (x,y)   -> (occur var x) || (occur var y)
    | Tproduct (x,y) -> (occur var x) || (occur var y)
    | Tvar v         -> V.equal var v
    | _              -> false


(* unify : typ -> typ -> unit 
 * does the unification of two types *)
let rec unify t1 t2 =
    match (head t1, head t2) with
    | (Tinteger, Tinteger) -> ()
    | (Tchar, Tchar)       -> ()
    | (Tbool, Tbool)       -> ()
    | (TIO, TIO)           -> ()
    | (Tvar v1, Tvar v2) when V.equal v1 v2 -> ()
    | (Tvar v1 as t1,t2) -> if occur v1 t2 then unification_error t1 t2;
                            assert (v1.def = None);
                            v1.def <- Some t2
    | (t1, Tvar v2) -> unify t2 t1
    | (Tarrow (t1,t1'), Tarrow(t2,t2')) -> unify t1 t2; unify t1' t2'
    | (Tproduct (t1,t1'), Tproduct(t2,t2')) -> unify t1 t2; unify t1' t2'
    | (t1,t2) -> unification_error t1 t2
