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
  | Elet of bindings * expr
  | Eif of expr * expr * expr
  | Ecase of expr * expr * ident * ident * expr
  | Edo of expr list
  | Ereturn
  | Etrue
  | Eint of int
  | Echar of char
  | EemptyList
  
and decl =
  | Let of string * expr
  | Letfun of string * expr

type prog = decl list
