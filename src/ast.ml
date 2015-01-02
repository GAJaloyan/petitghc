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

type const = True of loc 
    | False of loc 
    | Int of int * loc 
    | Char of char * loc 
    | String of string * loc

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
    | Single of simple_expr (* a single simple_expr: the base case for function application *)
    | App    of expr * simple_expr * loc
    | Lambda of ident * expr
    | Fun    of ident list * expr
    | Neg    of expr * loc
    | BinOp  of expr * op * expr * loc
    | If     of expr * expr * expr * loc
    | Let    of bindings * expr * loc
    | Case   of expr * expr * ident * ident * expr * loc
    | Do     of expr list * loc
    | Return of loc

and definition = ident * expr * loc

and bindings = definition list * loc

type file = definition list

let print_dec i =
    for j = 1 to i do
        Printf.printf " "
    done

let rec print_expr d = function
    | Single se ->
         print_dec d;
         Printf.printf "Single(\n";
         print_simple_expr (d+2) se;
         print_dec d;
         Printf.printf ")\n"
    | App (e,se,_) ->
         print_dec d;
         Printf.printf "App(\n";
         print_expr (d+2) e;
         print_simple_expr (d+2) se;
         print_dec d;
         Printf.printf ")\n"
    | Lambda (i, e) ->
         print_dec d;
         Printf.printf "Lambda(%s\n" i;
         print_expr (d+2) e;
         print_dec d;
         Printf.printf ")\n"
    | Fun (is, e) ->
         print_dec d;
         Printf.printf "Fun(";
         List.iter (fun x -> Printf.printf "%s," x) is;
         Printf.printf "\n";
         print_expr (d+2) e;
         print_dec d;
         Printf.printf ")\n"
    | Neg (e,_) ->
         print_dec d;
         Printf.printf "Neg(\n";
         print_expr (d+2) e;
         print_dec d;
         Printf.printf ")\n"
    | BinOp (e1,o,e2,_) ->
         print_dec d;
         Printf.printf "BinOp(\n";
         print_expr (d+2) e1;
         print_dec (d+2);
         Printf.printf ",%s,\n" (op_to_string o);
         print_expr (d+2) e2;
         print_dec d;
         Printf.printf ")";
    | If (e1,e2,e3,_) ->
         print_dec d;
         Printf.printf "If(\n";
         print_expr (d+2) e1;
         print_expr (d+2) e2;
         print_expr (d+2) e3;
         print_dec d;
         Printf.printf ")"
    | Let ((ds,_),e,_) ->
         print_dec d;
         Printf.printf "Let(\n";
         List.iter (fun def -> print_def (d+2) def) ds;
         print_expr (d+2) e;
         print_dec d;
         Printf.printf ")\n";
    | Case (e1,e2,i1,i2,e3,_) ->
         print_dec d;
         Printf.printf "Case(\n";
         print_expr (d+2) e1;
         print_expr (d+2) e2;
         print_dec (d+2);
         Printf.printf ",%s,%s,\n" i1 i2;
         print_expr (d+2) e3;
         print_dec d;
         Printf.printf ")\n"
    | Do (es,_) ->
         print_dec d;
         Printf.printf "Do(\n";
         List.iter (fun e -> print_expr (d+2) e) es;
         print_dec d;
         Printf.printf ")\n"
    | Return _ -> print_dec d; Printf.printf "Return\n"

and print_simple_expr d = function
    | Par  (e,_) ->
         print_dec d;
         Printf.printf "Par(\n";
         print_expr (d+2) e;
         print_dec d;
         Printf.printf ")\n"
    | Id   (i,_) ->
         print_dec d;
         Printf.printf "Id(%s)\n" i;
    | Cst  (c,_) ->
         print_dec d;
         Printf.printf "Cst(%s)\n" (const_to_string c)
    | List (es,_) ->
         print_dec d;
         Printf.printf "List(\n";
         List.iter (fun e -> print_expr (d+2) e) es;
         print_dec d;
         Printf.printf ")\n"

and print_def d (i,e,_) =
    print_dec d;
    Printf.printf "Def(%s,\n" i;
    print_expr (d+2) e;
    print_dec d;
    Printf.printf ")\n"

and print_file f =
    List.iter (fun d -> print_def 0 d; Printf.printf "\n") f
