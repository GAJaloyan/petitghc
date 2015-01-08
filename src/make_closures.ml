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
let nbGlobals = ref 6

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
   let name = ref ("_fun" ^ (string_of_int !closureNb)) in
   while SSet.mem !name !globalNames do
     incr closureNb;
     name := ("_fun" ^ (string_of_int !closureNb))
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
   let i = ref 4 in (* in a closure, the first two entries are the function
                       name and a type of value indication *)
   let closureEnv = SSet.fold 
     (fun x acc -> 
        if SMap.mem x env 
          then (i := !i+4; SMap.add x (C.Vclos !i) acc)
          else acc)
     freevars_of_e
     SMap.empty
   in (closure, closureEnv)

(** next is the number of items on the current frame 
 *  env is the environment minus the global environment *)
let rec transforme env next = function
   | I.Thunk e ->
       let (closure, closureEnv) = getClosure env e in
       let f = getClosureName () in
       let (e',fpmax) = transforme closureEnv 0 e in
       globalDefs := (C.Letfun (f,e',fpmax)) :: !globalDefs;
       C.Ethunk (C.Eclos (f, closure)), next
   | I.App (e1, e2) ->
       let e1', fpmax' = transforme env next e1 in
       let e2', fpmax2 = transforme env (max fpmax' next) e2 in
       C.Eapp (e1', e2'), next
   | I.Lambda (x,e) ->
       let funEnv = SMap.add x C.Varg env in
       let (closure, closureEnv) = getClosure funEnv e in
       let f = getClosureName () in
       let (e',fpmax) = transforme closureEnv 0 e in
       globalDefs := (C.Letfun (f,e',fpmax)) :: !globalDefs;
       C.Eclos (f, closure), next
   | I.Neg e ->
       let e, fpmax = transforme env next e in
       C.Eneg e, fpmax
   | I.BinOp (e1,op,e2) ->
       let e1', fpmax1 = transforme env next e1 in
       let e2', fpmax2 = transforme env next e2 in
       C.EbinOp (e1', inter_op_closured op, e2'), max fpmax1 fpmax2
   | I.Let (bs, e) ->
       let bindLoc = ref next in
       let env' = List.fold_left
         (fun acc (x,_) -> 
            let s = SMap.add x (C.Vlocal (- !bindLoc)) acc in
            bindLoc := !bindLoc + 4;
            s)
         env
         bs in
       let nextFree = !bindLoc in
       let bindLoc = ref next in
       let bs',fpmax1 = List.fold_left
         (fun (l,fpmax) (x,e) -> 
             let e,fpmax' = transforme env' nextFree e in
             bindLoc := !bindLoc + 4; 
             ((- (!bindLoc-4), e)::l, max fpmax fpmax')
         )
         ([],nextFree) bs in
       let e',fpmax2 = transforme env' nextFree e in
       C.Elet (bs',e'), max fpmax1 fpmax2
   | I.If (e1, e2, e3) ->
       let e1',fpmax1 = transforme env next e1 in
       let e2',fpmax2 = transforme env next e2 in
       let e3',fpmax3 = transforme env next e3 in
       C.Eif (e1', e2', e3'), max (max fpmax1 fpmax2) fpmax3
   | I.Case (e1, e2, i1, i2, e3) ->
       let e1',fpmax1 = transforme env next e1 in
       let e2',fpmax2 = transforme env next e2 in
       let env' = SMap.add i1 (C.Vlocal (-next))
                    (SMap.add i2 (C.Vlocal (-next-4)) env) in
       let e3',fpmax3 = transforme env' (next+8) e3 in
       C.Ecase (e1', e2', -next, -next-4, e3')
       , max (max fpmax1 fpmax2) fpmax3
   | I.Do es ->
       let l,fpmax = List.fold_left
         (fun (l,fpmax) e -> 
            let e,fpmax' = transforme env next e in
            (e::l, max fpmax fpmax'))
         ([],next)
         es in
       C.Edo l, fpmax 
   | I.Return ->
       C.Ereturn, next
   | I.Id x ->
       C.Evar (
         if SMap.mem x env then
           SMap.find x env
         else
           C.Vglobal x
       ), next
   | I.True ->
       C.Etrue, next
   | I.False ->
       C.Efalse, next
   | I.Int n ->
       C.Eint n, next
   | I.Char c ->
       C.Echar c, next
   | I.EmptyList ->
       C.EemptyList, next

(* transform the input into a representation with closure and allocates the
 * place of the local variables *)
let transform f =
   List.iter (fun (x,_) -> globalNames := SSet.add x !globalNames) f;
   let envbase = 
     List.fold_left (fun acc (x,e) -> SMap.add x (C.Vglobal x) acc)
     (SMap.add "putChar" (C.Vglobal "putChar")
       (SMap.add "error" (C.Vglobal "error")
         (SMap.add "rem" (C.Vglobal "rem")
           (SMap.singleton "div" (C.Vglobal "div")))))
     f in
   (List.map (fun (x,e) -> 
           let (e,fpmax) = transforme (SMap.empty) 0 e in
           let funname = getClosureName () in
           globalDefs := (C.Letfun (funname, e, fpmax)) :: !globalDefs;
           C.Let ((if x = "main" then "_main" else x),funname)) f) 
     @ !globalDefs
