let ast_op_inter = function
   | Ast.Plus -> Inter.Plus
   | Ast.Minus -> Inter.Minus
   | Ast.Time -> Inter.Time
   | Ast.LowerEq -> Inter.LowerEq
   | Ast.GreaterEq -> Inter.GreaterEq
   | Ast.Greater -> Inter.Greater
   | Ast.Lower -> Inter.Lower
   | Ast.Unequal -> Inter.Unequal
   | Ast.Equal -> Inter.Equal
   | Ast.And -> Inter.And
   | Ast.Or -> Inter.Or
   | Ast.Colon -> Inter.Colon

let rec simpe = function
   | Ast.Single se -> 
       simpse se
   | Ast.App (e1, e2,_) -> 
       Inter.App (simpe e1, Inter.Thunk (Inter.Lambda ("_",simpse e2)))
   | Ast.Lambda (x,e) -> 
       Inter.Lambda (x, simpe e)
   | Ast.Fun (xs,e) -> 
       List.fold_right (fun x acc -> Inter.Lambda (x,acc)) xs (simpe e)
   | Ast.Neg (e,_) -> 
       Inter.Neg (simpe e)
   | Ast.BinOp (e1,o,e2,_) -> 
       Inter.BinOp (simpe e1, ast_op_inter o, simpe e2)
   | Ast.If (e1,e2,e3,_) -> 
       Inter.If (simpe e1, simpe e2, simpe e3)
   | Ast.Let ((bs,_), e,_) -> 
       Inter.Let 
         (List.map 
           (fun (x,e,_) -> (x, Inter.Thunk (Inter.Lambda ("_", simpe e)))) 
           bs, 
         simpe e)
   | Ast.Case (e1,e2,i1,i2,e3,_) ->
       Inter.Case (simpe e1, simpe e2, i1, i2, simpe e3)
   | Ast.Do (es,_) -> 
       Inter.Do (List.map simpe es)
   | Ast.Return _ ->
       Inter.Return

and simpse = function
   | Ast.Par (e,_) -> simpe e
   | Ast.Id (i,_) -> Inter.Id i
   | Ast.Cst (c,_) -> simpc c
   | Ast.List (l,_) ->
       List.fold_right 
         (fun e acc -> Inter.BinOp (simpe e, Inter.Colon, acc))
         l
         Inter.EmptyList

and simpc = function
   | Ast.True _ -> Inter.True
   | Ast.False _ -> Inter.False
   | Ast.Int (n,_) -> Inter.Int n
   | Ast.Char (c,_) -> Inter.Char c
   | Ast.String (s,_) ->
       let rep = ref Inter.EmptyList in
       for i = pred (String.length s) downto 0 do
          rep := Inter.BinOp(Inter.Char s.[i], Inter.Colon, !rep)
       done;
       !rep

let simplify f = 
   List.map (fun (x,e,_) -> (x, Inter.Thunk (Inter.Lambda ("_", simpe e)))) f
