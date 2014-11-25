type ident = string

type loc = Lexing.position * Lexing.position

type op = Plus | Minus | Time | LowerEq | GreaterEq | Greater | Lower | Unequal
        | Equal | And | Or | Colon

type const = True of loc | False of loc | Int of int * loc | Char of char * loc | String of string * loc

type simple_expr =
    | Par  of (expr * loc) 
    | Id   of (ident * loc) 
    | Cst  of (const * loc) 
    | List of ((expr list) * loc)

and expr =
    | Simple of (simple_expr list) * loc
    | Lambda of (ident list) * expr * loc
    | Neg of expr * loc
    | BinOp of expr * op * expr * loc
    | If of expr * expr * expr * loc
    | Let of bindings * expr * loc
    | Case of expr * expr * ident * ident * expr * loc
    | Do of expr list * loc
    | Return of loc

and definition = ident * (ident list) * expr * loc

and bindings = Def of definition * loc | ListDef of definition list * loc

type file = definition list
