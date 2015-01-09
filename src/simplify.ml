let ast_op_inter = function
   | Adapt.Plus -> Inter.Plus
   | Adapt.Minus -> Inter.Minus
   | Adapt.Time -> Inter.Time
   | Adapt.LowerEq -> Inter.LowerEq
   | Adapt.GreaterEq -> Inter.GreaterEq
   | Adapt.Greater -> Inter.Greater
   | Adapt.Lower -> Inter.Lower
   | Adapt.Unequal -> Inter.Unequal
   | Adapt.Equal -> Inter.Equal
   | Adapt.And -> Inter.And
   | Adapt.Or -> Inter.Or
   | Adapt.Colon -> Inter.Colon

let rec simpe = function
   | Adapt.Single se -> 
       simpse se
   | Adapt.App (e1, e2,_) -> 
       Inter.App (simpe e1, Inter.Thunk (Inter.Lambda ("_",simpse e2)))
   | Adapt.Lambda (x,e) -> 
       Inter.Lambda (x, simpe e)
   | Adapt.Fun (xs,e) -> 
       List.fold_right (fun x acc -> Inter.Lambda (x,acc)) xs (simpe e)
   | Adapt.Neg (e,_) -> 
       Inter.Neg (simpe e)
   | Adapt.BinOp (e1,o,e2,_) -> 
       Inter.BinOp (Inter.Thunk (Inter.Lambda ("_",(simpe e1))), ast_op_inter o, Inter.Thunk (Inter.Lambda ("_",(simpe e2))))
   | Adapt.If (e1,e2,e3,_) -> 
       Inter.If (simpe e1, simpe e2, simpe e3)
   | Adapt.Let ((bs,_), e,_) -> 
       (* the thunks will be added during compilation *)
       Inter.Let 
         (List.map 
           (fun (x,e,_) -> (x, (Inter.Lambda ("_", simpe e))))
           bs, 
         simpe e)
   | Adapt.Case (e1,e2,i1,i2,e3,_) ->
       Inter.Case (simpe e1, simpe e2, i1, i2, simpe e3)
   | Adapt.Do (es,_) -> 
       Inter.Do (List.map simpe es)
   | Adapt.Return _ ->
       Inter.Return

and simpse = function
   | Adapt.Par (e,_) -> simpe e
   | Adapt.Id (i,_) -> Inter.Id i
   | Adapt.Cst (c,_) -> simpc c
   | Adapt.List (l,_) ->
       List.fold_right 
         (fun e acc -> Inter.BinOp (simpe e, Inter.Colon, Inter.Thunk (Inter.Lambda ("_",acc))))
         l
         Inter.EmptyList

and simpc = function
   | Adapt.True _ -> Inter.True
   | Adapt.False _ -> Inter.False
   | Adapt.Int (n,_) -> Inter.Int n
   | Adapt.Char (c,_) -> Inter.Char c
   | Adapt.String (s,_) ->
       let rep = ref Inter.EmptyList in
       for i = pred (String.length s) downto 0 do
          rep := Inter.BinOp(Inter.Char s.[i], Inter.Colon, !rep) (* no need to add a thunk 
                                                                   * because a char is already evaluated *)
       done;
       !rep

let simplify f = 
   List.map (fun (x,e,_) -> (x, Inter.Thunk (Inter.Lambda ("_", simpe e)))) f
