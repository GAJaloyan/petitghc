type op = Plus | Minus | Time | LowerEq | GreaterEq | Greater | Lower | Unequal
        | Equal | And | Or | Colon

let string_of_op = function
  | Plus -> "Plus" | Minus -> "Minus" | Time -> "Time" | LowerEq -> "LowerEq"
  | GreaterEq -> "GreaterEq" | Greater -> "Greater" | Lower -> "Lower"
  | Unequal -> "Unequal" | Equal -> "Equal" | And -> "And" | Or -> "Or"
  | Colon -> "Colon"

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
  | Let of string * string (* as the only free variables in a global let
                              are globals, they don't need to be put
                              in the closure, so that the only thing
                              we need to know is the name of the closure *)
  | Letfun of string * expr * (* fpmax *) int

type prog = decl list

let print_space d = for i = 1 to d do Printf.printf "  " done

let print_var d = function
  | Vglobal s -> print_space d; Printf.printf "Vglobal(%s)\n" s
  | Vlocal i -> print_space d; Printf.printf "Vlocal(%d)\n" i
  | Vclos i -> print_space d; Printf.printf "Vclos(%d)\n" i
  | Varg -> print_space d; Printf.printf "Varg\n"

let rec print_expr d = function
  | Evar v -> print_var d v
  | Eclos (x,bs) ->
       print_space d;
       Printf.printf "Eclos(%s,\n" x;
       List.iter (print_var (d+1)) bs;
       print_space d;
       Printf.printf ")\n"
  | Eapp (e1,e2) ->
       print_space d;
       Printf.printf "Eapp(\n";
       print_expr (d+1) e1;
       print_space d;
       Printf.printf ",\n";
       print_expr (d+2) e2;
       print_space d;
       Printf.printf ")\n"
  | Ethunk e ->
       print_space d;
       Printf.printf "Ethunk(\n";
       print_expr (d+1) e;
       print_space d;
       Printf.printf ")\n"
  | Elet (vs, e) ->
       print_space d;
       Printf.printf "Elet(\n";
       List.iter
         (fun (x,e) ->
                 print_space (d+1); Printf.printf "%s,\n", x;
                 print_expr (d+2) e;
                 print_space (d+1); Printf.printf ",\n")
         vs;
       print_expr (d+1) e;
       print_space d;
       Printf.printf ")\n"
  | Eif (e1,e2,e3) ->
       print_space d; Printf.printf "Eif(\n";
       print_expr (d+1) e1; print_space d; Printf.printf ",\n";
       print_expr (d+1) e2; print_space d; Printf.printf ",\n";
       print_expr (d+1) e3; print_space d; Printf.printf ")\n"
  | Ecase (e1,e2,i1,i2,e3) ->
       print_space d;
       Printf.printf "Ecase(\n";
       print_expr (d+1) e1; print_space d; Printf.printf ",\n";
       print_expr (d+1) e2; print_space d; Printf.printf ",\n";
       print_space d; Printf.printf "%d, %d,\n" i1 i2;
       print_expr (d+1) e3; print_space d; Printf.printf ")\n"
  | Edo es ->
       print_space d;
       Printf.printf "Edo(\n";
       List.iter (fun e -> print_expr (d+1) e; print_space d; Printf.printf ",\n") es;
       print_space d;
       Printf.printf ")\n"
  | Ereturn -> print_space d; Printf.printf "Ereturn \n"
  | Eneg e ->
       print_space d;
       Printf.printf "Eneg(\n";
       print_expr (d+1) e;
       print_space d;
       Printf.printf ")\n"
  | EbinOp (e1,o,e2) ->
       print_space d; Printf.printf "EbinOp\n";
       print_expr (d+1) e1; print_space d; Printf.printf ",\n";
       print_space d; Printf.printf "%s\n" (string_of_op o);
       print_expr (d+1) e2; print_space d; Printf.printf ")\n"
  | Etrue -> print_space d; Printf.printf "Etrue"
  | Efalse -> print_space d; Printf.printf "Efalse"
  | Eint i -> print_space d; Printf.printf "Eint(%d)\n" d
  | Echar c -> print_space d; Printf.printf "Echar(%c)\n" c
  | EemptyList -> print_space d; Printf.printf "EemptyList\n"

let print_decl = function
  | Let(x,y) -> Printf.printf "Let(%s,%s)\n" x y
  | Letfun(x,e,i) ->
      Printf.printf "Letfun(%s,\n" x;
      print_expr 0 e;
      Printf.printf "%d)\n" i

let print_prog = List.iter print_decl
