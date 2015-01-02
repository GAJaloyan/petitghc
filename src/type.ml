module E = Error

(* abstract syntax of the types *)
type typ = Tbool 
         | Tchar 
         | Tinteger
         | TIO
         | Tvar of tvar
         | Tarrow of typ * typ
         | Tlist of typ
and tvar =
    { id : int;
      mutable def : typ option }

let type_to_string t = 
    let b = Buffer.create 17 in
    let rec aux = function
    | Tbool    -> Buffer.add_string b "Bool"
    | Tchar    -> Buffer.add_string b "Char"
    | Tinteger -> Buffer.add_string b "Integer"
    | TIO      -> Buffer.add_string b "IO"
    | Tvar v   -> begin match v.def with
                  | Some t -> aux t
                  | None -> Buffer.add_string b "Tvar"
                  end
    | Tarrow (t1,t2) -> Buffer.add_string b "("; aux t1; 
                        Buffer.add_string b ") -> "; aux t2;
    | Tlist t -> Buffer.add_string b "List ("; aux t; Buffer.add_string b ")"
    in
    aux t;
    Buffer.contents b

let print_type t = Printf.printf "%s" (type_to_string t)

(* module that encapsulates types variables and provides a function to 
 * compare them *)
module V = struct
    type t = tvar
    let compare v1 v2 = Pervasives.compare v1.id v2.id
    let equal v1 v2 = v1.id = v2.id
    let create = let r = ref 0 in fun () -> incr r; { id = !r; def = None }
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
| Tlist x        -> Tlist (canon x)
| x              -> x

exception UnificationFailure of typ * typ * Ast.loc

let unification_error t1 t2 pos = raise (UnificationFailure
    (canon t1, canon t2, pos))

(* occur : tvar -> typ -> bool
 * checks the occurence of a type variable inside a type, we can
 * suppose the variable is undefined *)
let rec occur v t =
    match (head t) with
    | Tarrow (t1,t2) -> occur v t1 || occur v t2
    | Tlist t        -> occur v t
    | Tvar w         -> V.equal v w
    | _              -> false


(* unify : typ -> typ -> unit 
 * does the unification of two types *)
let unify s1 s2 pos =
    let rec aux t1 t2 =
        match (head t1, head t2) with
        | Tinteger, Tinteger -> ()
        | Tchar, Tchar       -> ()
        | Tbool, Tbool       -> ()
        | TIO, TIO           -> ()
        | Tvar v1, Tvar v2 when V.equal v1 v2 -> ()
        | Tvar v1 as t1,t2 -> 
                if occur v1 t2 then unification_error s1 s2 pos;
                assert (v1.def = None);
                v1.def <- Some t2
        | t1, Tvar v2 -> aux t2 t1
        | Tarrow (t1,t1'), Tarrow(t2,t2') -> aux t1 t2; aux t1' t2'
        | Tlist t1, Tlist t2 -> aux t1 t2
        | (t1,t2) -> unification_error s1 s2 pos
    in aux s1 s2

(* schema de type *)
module Vset = Set.Make(V)

type schema = { vars : Vset.t; typ : typ }

(* free variables *)

let rec fvars t = match head t with
| Tarrow (t1, t2) -> Vset.union (fvars t1) (fvars t2)
| Tvar v  -> Vset.singleton v
| Tlist v -> fvars v
| _       -> Vset.empty

let norm_varset s =
    Vset.fold (fun v s -> Vset.union (fvars (Tvar v)) s) s Vset.empty

(* environnement c'est une table de bindings (string -> schema),
 * et un ensemble de variables de types libres *)

module Smap = Map.Make(String)

type env = { bindings : schema Smap.t; fvars : Vset.t }

let empty = { bindings = Smap.empty; fvars = Vset.empty }


let add gen x t env =
    let vt = fvars t in
    let s, fvars =
        if gen then
            let env_fvars = norm_varset env.fvars in
            { vars = Vset.diff vt env_fvars; typ = t }, env.fvars
        else
            { vars = Vset.empty; typ = t }, Vset.union env.fvars vt
    in
    { bindings = Smap.add x s env.bindings; fvars = fvars }

let base =  List.fold_left (fun acc (x,t) -> add true x t acc)
            empty
            ["div"    , Tarrow (Tinteger, Tarrow (Tinteger, Tinteger));
             "rem"    , Tarrow (Tinteger, Tarrow (Tinteger, Tinteger));
             "error"  , Tarrow (Tlist Tchar, Tvar (V.create ()))      ;
             "putChar", Tarrow (Tchar, TIO)
            ] 

module Vmap = Map.Make(V)

(* find x env donne une instance fraîche de env(x) *)
let find x env =
    try begin
    let tx = Smap.find x env.bindings in
    let s =
        Vset.fold (fun v s -> Vmap.add v (Tvar (V.create ())) s)
            tx.vars Vmap.empty
    in
    let rec subst t = match head t with
    | Tvar x as t -> (try Vmap.find x s with Not_found -> t)
    | Tinteger    -> Tinteger
    | TIO         -> TIO
    | Tchar       -> Tchar
    | Tbool       -> Tbool
    | Tlist t     -> Tlist (subst t)
    | Tarrow (t1, t2) -> Tarrow (subst t1, subst t2)
    in
    subst tx.typ
    end with Not_found -> failwith x

let no_duplicates =
    let rec aux = function
        | (x1::x2::xs) when x1 = x2 -> false
        | (x::xs)                  -> aux xs
        | []                       -> true
    in fun x -> aux (List.sort compare x)

(* W algorithm *)
let rec w env t = (*Ast.print_expr 0 t; Printf.printf "\n";*)
    match t with
    | Ast.Single e ->
        ws env e
    | Ast.App (e1,e2,pos) ->
        let t1 = w env e1 and t2 = ws env e2 in
        let v = Tvar (V.create()) in
        (*Printf.printf "Unifying app\n";*)
        unify t1 (Tarrow (t2,v)) pos;
        (*Printf.printf "Done unifying app\n";*)
        v
    | Ast.Lambda (x,e) -> 
        let v = Tvar (V.create ()) in
        let env = add false x v env in
        let t = w env e in
        Tarrow (v, t)
    | Ast.Fun (xs,e) ->
        let vs = List.map (fun _ -> Tvar (V.create())) xs in
        let env' = List.fold_left2 (fun env i v -> add false i v env) env xs vs in
        let t = w env' e in
        if not (no_duplicates xs) then raise (E.SemantError "Duplicate variable in lambda expresssion.");
        (*Printf.printf "done with fun\n";*)
        List.fold_right (fun v t -> Tarrow(v,t)) vs t
    | Ast.Neg (e,pos) ->
        unify Tinteger (w env e) pos;
        Tinteger
    | Ast.BinOp (e1,o,e2,pos) ->
        let t1 = w env e1 and t2 = w env e2 in
        begin match o with
        | Ast.Plus | Ast.Minus | Ast.Time ->
            unify t1 Tinteger pos; unify t2 Tinteger pos;
            Tinteger
        | Ast.LowerEq | Ast.GreaterEq | Ast.Greater | Ast.Lower | Ast.Unequal | Ast.Equal ->
            unify t1 Tinteger pos; unify t2 Tinteger pos;
            Tbool
        | Ast.And | Ast.Or ->
            unify t1 Tbool pos; unify t2 Tbool pos;
            Tbool
        | Ast.Colon ->
            unify (Tlist t1) t2 pos; Tlist t1
        end
    | Ast.If (e1,e2,e3,pos) ->
        let t1 = w env e1 and t2 = w env e2 and t3 = w env e3 in
        unify t1 Tbool pos;
        unify t2 t3 pos;
        t2
    | Ast.Let ((bs,_), e, _) ->
        let vs = List.map (fun _ -> Tvar (V.create ())) bs in
        let env' = List.fold_left2 (fun acc (x,_,_) v -> add false x v acc) env bs vs in
        (* types the body of each binding *)
        List.iter2 (fun (_,e1,pos) v1 -> unify (w env' e1) v1 pos) bs vs;
        (* checks no duplicates in the names of the bindings *)
        (*Printf.printf "%d\n" (List.length bs);*)
        if not (no_duplicates (List.map (fun (x,_,_) -> x) bs)) then
            raise (E.SemantError "Duplicate bindings in a let expression");
        (* types the body of the let expression *)
        let env'' = List.fold_left2 (fun acc (x,_,_) v -> add true x v acc) env bs vs in
        w env'' e
    | Ast.Case (e1,e2,x1,x2,e3,pos) ->
        let t1 = w env e1 and t2 = w env e2 in
        let t1' = Tvar (V.create()) in
        unify t1 (Tlist t1') pos;
        let env' = add true x2 t1 (add true x1 t1' env) in
        let t3 = w env' e3 in
        if x1 = x2 then raise (E.SemantError "Duplicate variable in the pattern matching");
        (* checks that e2 and e3 have the same type *)
        unify t3 t2 pos;
        (*print_type t1; Printf.printf "\n";
        print_type t2; Printf.printf "\n";
        print_type t3; Printf.printf "\n";*)
        t2
    | Ast.Do (es,pos) -> 
        List.iter (fun e -> unify (w env e) TIO pos) es;
        (*Printf.printf "done with do\n";*)
        TIO
    | Ast.Return _ -> TIO

and ws env = function (* type of simple expressions *)
    | Ast.Par (e,_)            -> w env e
    | Ast.Id (x,_)             -> find x env
    | Ast.Cst (Ast.Int _,_)    -> Tinteger
    | Ast.Cst (Ast.Char _,_)   -> Tchar
    | Ast.Cst (Ast.String _,_) -> Tlist Tchar
    | Ast.Cst _                -> Tbool
    | Ast.List ([],p)          -> Tlist (Tvar (V.create ()))
    | Ast.List (es,p)          ->
        let v = Tvar (V.create ()) in
        List.iter (fun e -> unify (w env e) v p) es;
        Tlist v

and wd env = function
    | (x,_,e,_) -> w env e

and wf env f =
    let check_main vs f =
        let rec aux = function
            | ((v::vs),((x,_,pos)::ds)) when x = "main" ->
                    unify v TIO pos
            | ((_::vs),(_::ds)) -> aux (vs,ds)
            | ([],[]) -> raise (E.SemantError "No main")
        in aux (vs,f) in
    let vs = List.map (fun _ -> Tvar (V.create ())) f in
    let env' = List.fold_left2 (fun acc (x,_,_) v -> add false x v acc) env f vs in
    (* checks no duplicates in the name of the global bindings *)
    if not (no_duplicates (List.map (fun (x,_,_) -> x) f)) then
        raise (E.SemantError "Duplicate bindings in a let expression");
    (* Carries out the typing of the declarations *)
    List.iter2 (fun (x,e,p) v -> (*Printf.printf "Doing %s\n" x;*) unify (w env' e) v p(*; Printf.printf "Done with %s\n" x*)) f vs;
    (* check that main is there with type IO *)
    check_main vs f

let infer (f : Ast.file) =
    wf base f


