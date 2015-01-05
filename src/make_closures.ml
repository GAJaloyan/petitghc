let ast_op_inter = function
   | Inter.Plus -> Ast.Plus
   | Inter.Minus -> Ast.Minus
   | Inter.Time -> Ast.Time
   | Inter.LowerEq -> Ast.LowerEq
   | Inter.GreaterEq -> Ast.GreaterEq
   | Inter.Greater -> Ast.Greater
   | Inter.Lower -> Ast.Lower
   | Inter.Unequal -> Ast.Unequal
   | Inter.Equal -> Ast..Equal
   | Inter.And -> Ast.And
   | Inter.Or -> Ast.Or
   | Inter.Colon -> Ast..Colon

module SSet = Set.Make(String)

let globalNames = ref SSet.empty

let freevars = function
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
   | Inter.Case (e1, e2, i1, i2, i3) ->
       SSet.union
         (SSet.union (freevars e1) (freevars e2))
         (SSet.remove i1 (SSet.remove i2 (freevars e3)))
   | Inter.Do es ->
       List.fold_left
         SSet.union
         SSet.empty
         (List.map freevars es)
   | Inter.Id i -> SSet.singleton i
   | _ -> SSet.empty
