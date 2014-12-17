(* astract syntax tree for the language *)

type ident = string

type loc = Lexing.position * Lexing.position

type op = Plus | Minus | Time | LowerEq | GreaterEq | Greater | Lower | Unequal
        | Equal | And | Or | Colon

let op_to_string = function
    | Plus      -> "Plus"
    | Minus     -> "Minus"
    | Time      -> "Time"
    | LowerEq   -> "LowerEq"
    | GreaterEq -> "GreaterEq"
    | Greater   -> "Greater"
    | Lower     -> "Lower"
    | Unequal   -> "Unequal"
    | Equal     -> "Equal"
    | And       -> "And"
    | Or        -> "Or"
    | Colon     -> "Colon"

type const = True of loc | False of loc | Int of int * loc | Char of char * loc | String of string * loc

let const_to_string = function
    | True _       -> "True"
    | False _      -> "False"
    | Int (i,_)    -> "Int " ^ (string_of_int i)
    | Char (c,_)   -> "Char " ^ (String.make 1 c)
    | String (s,_) -> "String " ^ s

type simple_expr =
    | Par  of (expr * loc) 
    | Id   of (ident * loc) 
    | Cst  of (const * loc) 
    | List of ((expr list) * loc)

and expr =
    | Simple of (simple_expr list) * loc
    (* those two are used to convert a list of simple expressions 
     * which is just syntactic sugar for one currying *)
    | Single of simple_expr
    | App of expr * simple_expr
    | Lambda of ident * expr
    | Neg of expr * loc
    | BinOp of expr * op * expr * loc
    | If of expr * expr * expr * loc
    | Let of bindings * expr * loc
    | Case of expr * expr * ident * ident * expr * loc
    | Do of expr list * loc
    | Return of loc

and definition = ident * (ident list) * expr * loc

and bindings = definition list * loc

type file = definition list

let rec print_expr = function
    | Simple (es,_) ->
         Printf.printf "Simple (";
         List.iter 
         (fun se -> print_simple_expr se; Printf.printf ", ")
         es;
         Printf.printf ")"
    (* those two are used to convert a list of simple expressions 
     * which is just syntactic sugar for one currying *)
    | Single se ->
         Printf.printf "Single(";
         print_simple_expr se;
         Printf.printf ")"
    | App (e,se) ->
         Printf.printf "App(";
         print_expr e;
         Printf.printf ",";
         print_simple_expr se;
         Printf.printf ")"
    | Lambda (i, e) ->
         Printf.printf "Lambda(";
         Printf.printf "%s," i;
         print_expr e;
         Printf.printf ")"
    | Neg (e,_) ->
         Printf.printf "Neg(";
         print_expr e;
         Printf.printf ")"
    | BinOp (e1,o,e2,_) ->
         Printf.printf "BinOp(";
         print_expr e1;
         Printf.printf ",%s," (op_to_string o);
         print_expr e2;
         Printf.printf ")";
    | If (e1,e2,e3,_) ->
         Printf.printf "If(";
         print_expr e1;
         Printf.printf ",";
         print_expr e2;
         Printf.printf ",";
         print_expr e3;
         Printf.printf ")"
    | Let ((ds,_),e,_) ->
         Printf.printf "Let(";
         List.iter 
         (fun d -> print_def d; Printf.printf ",")
         ds;
         Printf.printf ")";
    | Case (e1,e2,i1,i2,e3,_) ->
         Printf.printf "Case(";
         print_expr e1;
         Printf.printf ",";
         print_expr e2;
         Printf.printf ",%s,%s," i1 i2;
         print_expr e3;
         Printf.printf ")"
    | Do (es,_) ->
         Printf.printf "Do(";
         List.iter
         (fun e -> print_expr e; Printf.printf ",")
         es;
         Printf.printf ")"
    | Return _ -> Printf.printf "Return"

and print_simple_expr = function
    | Par  (e,_) ->
         Printf.printf "Par(";
         print_expr e;
         Printf.printf ")"
    | Id   (i,_) ->
         Printf.printf "Id(%s)" i;
    | Cst  (c,_) ->
         Printf.printf "Cst(%s)" (const_to_string c)
    | List (es,_) ->
         Printf.printf "List(";
         List.iter
         (fun e -> print_expr e; Printf.printf ",";)
         es;
         Printf.printf ")"

and print_def (i,is,e,_) =
    Printf.printf "Def(%s," i;
    List.iter (fun s -> Printf.printf "%s," s);
    print_expr e;
    Printf.printf ")"
