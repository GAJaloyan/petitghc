type op = Plus | Minus | Time | LowerEq | GreaterEq | Greater | Lower | Unequal
        | Equal | And | Or | Colon

type var =
  | Vglobal of string
  | Vlocal of int
  | Vclos of int
  | Varg

type expr =
  | Evar of var
  | Eclos of string * var list
  | Eapp of expr * expr
  | Ethunk of expr
  | Elet of ((int * expr) list) * expr
  | Eif of expr * expr * expr
  | Ecase of expr * expr * int * int * expr
  | Edo of expr list
  | Ereturn
  | Eneg of expr
  | EbinOp of expr * op * expr
  | Etrue
  | Efalse
  | Eint of int
  | Echar of char
  | EemptyList
  
and decl =
  | Let of string * expr
  | Letfun of string * expr * (* fpmax *) int

type prog = decl list
