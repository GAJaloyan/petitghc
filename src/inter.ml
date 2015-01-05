type ident = string

type op = Plus | Minus | Time | LowerEq | GreaterEq | Greater | Lower | Unequal
        | Equal | And | Or | Colon

type expr =
  | Thunk of expr
  | App of expr * expr
  | Lambda of ident * expr
  | Neg of expr
  | BinOp of expr * op * expr
  | Let of bindings * expr
  | If of expr * expr * expr
  | Case of expr * expr * ident * ident * expr
  | Do of expr list
  | Return
  | Id of ident
  | True
  | False
  | Int of int
  | Char of char
  | EmptyList

and definition = ident * expr

and bindings = definition list

type file = definition list
