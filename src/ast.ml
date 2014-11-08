type ident = string

type op = Plus | Minus | Time | LowerEq | GreaterEq | Greater | Lower | Unequal
        | Equal | And | Or | Colon

type const = True | False | Int of int | Char of char | String of string

type simple_expr =
    | Par of expr | Id of ident | Cst of const | List of (expr list)

and expr =
    | Simple of (simple_expr list)
    | Lambda of (ident list) * expr
    | Neg of expr
    | BinOp of expr * op * expr
    | If of expr * expr * expr
    | Let of bindings * expr
    | Case of expr * expr * ident * ident * expr
    | Do of expr list
    | Return

and definition = ident * (ident list) * expr

and bindings = Def of definition | ListDef of definition list

type file = definition list
