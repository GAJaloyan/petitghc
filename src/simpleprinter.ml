open Inter 
open String
open Printf

let i = ref 0


let identifier_operande op =
  match op with
  | Plus      -> "+"
  | Minus     -> "-"
  | Time      -> "*"
  | LowerEq   -> "<="
  | GreaterEq -> ">="
  | Greater   -> ">"
  | Lower     -> "<"
  | Unequal   -> "/="
  | Equal     -> "=="
  | And       -> "&&"
  | Or        -> "||"
  | Colon     -> ":"


let rec print_expr pere (e:Inter.expr) =
  match e with
  | Thunk(e) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Thunk\",color=lightblue1,style=filled]\n" s;
    printf "%s -> %s\n" pere s;
    print_expr s e
    end
  | App (e1, e2) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"App\",color=green4,style=filled]\n" s;
    printf "%s -> %s\n" pere s;
    print_expr s e1;
    print_expr s e2
    end
  | Lambda(id, expr) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Lambda \\\"%s\\\"\",color=mediumseagreen,style=filled]\n" s id;
    printf "%s -> %s\n" pere s;
    print_expr s expr
    end
  | Neg (e) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Neg\",color=darkseagreen,style=filled]\n" s;
    printf "%s -> %s\n" pere s;
    print_expr s e
    end
  | BinOp (e1, op, e2) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"BinOp %s\",color=darkseagreen,style=filled]\n" s (identifier_operande op);
    printf "%s -> %s\n" pere s;
    print_expr s e1;
    print_expr s e2
    end
  | Let (liste, expr) ->  let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Let\",color=green,style=filled]\n" s;
    printf "%s -> %s\n" pere s;
    print_deflist s liste;
    print_expr s expr
    end
  | If(cond,e1,e2) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"If\",color=green,style=filled]\n" s;
    printf "%s -> %s\n" pere s;
    print_expr s cond;
    print_expr s e1;
    print_expr s e2
    end
  | Case(expr, vide, id1,id2,expr2) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Case\",color=green,style=filled]\n" s;
    printf "%s -> %s\n" pere s;
    print_expr s expr;
      let s2 = (string_of_int !i) in begin
      i:= !i+1;
      printf "%s [label=\"[]\",color=gold,style=filled]\n" s2;
      printf "%s -> %s\n" s s2;
      print_expr s2 vide;end; 
    
      let s2 = (string_of_int !i) in begin
      i:= !i+1;
      printf "%s [label=\"%s:%s\",color=gold,style=filled]\n" s2 id1 id2;
      printf "%s -> %s\n" s s2;
      print_expr s2 expr2;end
    
    end
  | Do(liste) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Do\",color=green,style=filled]\n" s;
    printf "%s -> %s\n" pere s;
    print_liste s liste
    end
  | Return ->  let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Return\",color=greenyellow,style=filled]\n" s;
    printf "%s -> %s\n" pere s;
    end
  | Id (liste) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Id \\\"%s\\\"\",color=lightsalmon2,style=filled]\n" s liste;
    printf "%s -> %s\n" pere s
    end
  | True -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"True\",color=lightsalmon2,style=filled]\n" s;
    printf "%s -> %s\n" pere s
    end
  | False -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"False\",color=lightsalmon2,style=filled]\n" s;
    printf "%s -> %s\n" pere s
    end
  | Int (valeur) ->  let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Int %d\",color=lightsalmon2,style=filled]\n" s valeur;
    printf "%s -> %s\n" pere s
    end
  | Char(c) ->  let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Char %c\",color=lightsalmon2,style=filled]\n" s c;
    printf "%s -> %s\n" pere s
    end
  | EmptyList ->  let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"[]\",color=lightsalmon2,style=filled]\n" s;
    printf "%s -> %s\n" pere s
    end

and print_deflist pere (liste:Inter.definition list) =
  match liste with
  |[] -> ()
  |(id,expr)::b -> begin let s = (string_of_int !i)in 
  i := !i +1;
  printf "%s [label=\"%s\",color=crimson, style=filled]\n" s id;
  printf "%s -> %s\n" pere s;
  print_expr s expr;
  print_deflist pere b
  end
  
and print_liste pere (l:Inter.expr list) =
  match l with
  |[] -> ()
  |a::b -> print_expr pere a; print_liste pere b

and print_def (id,e) =
  begin let s = (string_of_int !i)in 
  i := !i +1;
  printf "%s [label=\"Def \\\"%s\\\"\",color=red, style=filled]\n" s id;
  print_expr s e;
  end

let rec print_prog prog =
  match prog with
  |[] -> ()
  |a::b -> begin
    print_def a;
    print_prog b
  end

let print_fichier (fichier:Inter.file) =
  begin
  printf "digraph G {\nnode [shape=box]\n";
  print_prog fichier;
  printf "\n}\n";
  end
  

