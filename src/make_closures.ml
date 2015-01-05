module I = Inter
module C = Closured

let inter_op_closured = function
   | Inter.Plus -> C.Plus
   | Inter.Minus -> C.Minus
   | Inter.Time -> C.Time
   | Inter.LowerEq -> C.LowerEq
   | Inter.GreaterEq -> C.GreaterEq
   | Inter.Greater -> C.Greater
   | Inter.Lower -> C.Lower
   | Inter.Unequal -> C.Unequal
   | Inter.Equal -> C.Equal
   | Inter.And -> C.And
   | Inter.Or -> C.Or
   | Inter.Colon -> C.Colon

module SSet = Set.Make(String)
module SMap = Map.Make(String)

let globalNames = ref SSet.empty
let globalDefs = ref []

let rec freevars = function
   | Inter.Thunk e -> freevars e
   | Inter.App (e1, e2) -> SSet.union (freevars e1) (freevars e2)
   | Inter.Lambda (x,e) -> SSet.remove x (freevars e)
   | Inter.Neg e -> freevars e
   | Inter.BinOp (e1,_,e2) -> SSet.union (freevars e1) (freevars e2)
   | Inter.Let (bs, e) ->
       let (xs, es) = List.split bs in
       List.fold_right
         SSet.remove
         xs
         (List.fold_left SSet.union (freevars e) (List.map freevars es))
   | Inter.If (e1,e2,e3) -> 
       SSet.union (freevars e1) (SSet.union (freevars e2) (freevars e3))
   | Inter.Case (e1, e2, i1, i2, e3) ->
       SSet.union
         (SSet.union (freevars e1) (freevars e2))
         (SSet.remove i1 (SSet.remove i2 (freevars e3)))
   | Inter.Do es ->
       List.fold_left
         SSet.union
         SSet.empty
         (List.map freevars es) | Inter.Id i -> SSet.singleton i
   | _ -> SSet.empty

let closureNb = ref 0

(* returns the next closure name available *)
let getClosureName () = 
   incr closureNb;
   let name = ref ("fun" ^ (string_of_int !closureNb)) in
   while SSet.mem !name !globalNames do
     incr closureNb;
     name := ("fun" ^ (string_of_int !closureNb))
   done;
   globalNames := SSet.add !name !globalNames;
   !name

let getClosure env e =
   let freevars_of_e = freevars e in
   let closure = SSet.fold
     (fun x acc ->
        if SMap.mem x env then
          (SMap.find x env)::acc
        else
          acc)
     freevars_of_e
     [] in
   let i = ref (-1) in
   let closureEnv = SSet.fold 
     (fun x acc -> 
        if SMap.mem x env 
          then (incr i; SMap.add x (C.Vclos !i) acc)
          else acc)
     freevars_of_e
     SMap.empty
   in (closure, closureEnv)

(** s is the number of items on the current frame 
 *  env is the environment minus the global environment *)
let rec transforme env s = function
   | I.Thunk e ->
       let (closure, closureEnv) = getClosure env e in
       let f = getClosureName () in
       let e' = transforme closureEnv 0 e in
       globalDefs := (C.Letfun (f,e')) :: !globalDefs;
       C.Eclos (f, closure)
   | I.App (e1, e2) ->
       let e1' = transforme env s e1 in
       let e2' = transforme env (s+1) e2 in (* save register $a1 *)
       C.Eapp (e1', e2')
   | I.Lambda (x,e) ->
       let (closure, closureEnv) = getClosure env e in
       let f = getClosureName () in
       let funEnv = SMap.add x C.Varg closureEnv in
       let e' = transforme closureEnv 0 e in
       globalDefs := (C.Letfun (f,e')) :: !globalDefs;
       C.Eclos (f, closure)
   | I.Neg e ->
       C.Eneg (transforme env s e)
   | I.BinOp (e1,op,e2) ->
       let e1' = transforme env s e1 in
       let e2' = transforme env (s+1) e2 in (* save value of e1 *)
       C.EbinOp (e1', inter_op_closured op, e2')
   | I.Let (bs, e) ->
       let bindLoc = ref s in
       let env' = List.fold_left
         (fun acc (x,_) -> incr bindLoc; SMap.add x (C.Vlocal !bindLoc) acc)
         env
         bs in
       let bindLoc = ref s in
       let bs' = List.map
         (fun (x,e) -> incr bindLoc; (!bindLoc, transforme env !bindLoc e))
         bs in
       let e' = transforme env' !bindLoc e in
       C.Elet (bs',e')
   | I.If (e1, e2, e3) ->
       let e1' = transforme env s e1 in
       let e2' = transforme env s e2 in
       let e3' = transforme env s e3 in
       C.Eif (e1', e2', e3')
   | I.Case (e1, e2, i1, i2, e3) ->
       let e1' = transforme env s e1 in
       let e2' = transforme env s e2 in
       let env' = SMap.add i1 (C.Vlocal (s+1))
                    (SMap.add i2 (C.Vlocal (s+2)) env) in
       let e3' = transforme env' (s+2) e3 in
       C.Ecase (e1', e2', (s+1), (s+2), e3')
   | I.Do es ->
       C.Edo (List.map (fun e -> transforme env s e) es)
   | I.Return ->
       C.Ereturn
   | I.Id x ->
       C.Evar (
         if SMap.mem x env then
           SMap.find x env
         else
           C.Vglobal x
       )
   | I.True ->
       C.Etrue
   | I.False ->
       C.Efalse
   | I.Int n ->
       C.Eint n
   | I.Char c ->
       C.Echar c
   | I.EmptyList ->
       C.EemptyList

let transform f =
   List.iter (fun (x,e) -> globalNames := SSet.add x !globalNames);
   (*let envbase = 
     List.fold_left (fun acc (x,e) -> SMap.add x (Vglobal x) acc)
     (SMap.add "putChar" (Vglobal "putChar")
       (SMap.add "error" (Vglobal "error")
         (SMap.add "rem" (Vglobal "rem")
           (SMap.singleton "div" (Vglobal "div")))))
     f*)
   (List.map (fun (x,e) -> C.Let (x, transforme (SMap.empty)0 e)) f) 
     @ !globalDefs
