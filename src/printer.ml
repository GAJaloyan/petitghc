open Ast 
open String
open Lexing
open Printf

let i = ref 0

let localisation (pos,_) =
  let l = pos.pos_lnum in
  let c = pos.pos_cnum - pos.pos_bol + 1 in (l,c)

let loclin (pos,_) =
  let l = pos.pos_lnum in (l)

let loccol (pos,_) =
  let c = pos.pos_cnum - pos.pos_bol + 1 in (c)


let string_implode l =
  let res = String.create (List.length l) in
  let rec imp i = function
  | [] -> res
  | c :: l -> res.[i] <- c; imp (i + 1) l in
  imp 0 l

let identifier_operande op =
  match op with
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Infe -> "<="
  | Supe -> ">="
  | Infs -> "<"
  | Sups -> ">"
  | Uneq -> "/="
  | Eq -> "=="
  | And -> "&&"
  | Or -> "||"
  | Head -> ":"

let print_const pere ({desc=const;loc=localisation}:Ast.const) =
  match const with
	|Ctrue -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Ctrue\nlin:%d col:%d\",color=skyblue1,style=filled]\n" s (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s
    end
	|Cfalse -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Cfalse\nlin:%d col:%d\",color=skyblue1,style=filled]\n" s (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s
    end
	|Cint(a) ->let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Cint %d\nlin:%d col:%d\",color=skyblue1,style=filled]\n" s a (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s
    end
	|Cchar(b) ->let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Cchar '%c'\nlin:%d col:%d\",color=skyblue1,style=filled]\n" s b (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s
    end
	|Cstring(liste) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Cstring \\\"%s\\\"\nlin:%d col:%d\",color=skyblue1,style=filled]\n" s (string_implode liste) (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s
    end

let rec print_atomiclist pere (l:Ast.simple_expr list) =
  match l with
  |[] -> ()
  |(hh:Ast.simple_expr)::b -> let ({desc=a;loc=localisation}:Ast.simple_expr) = hh in begin 
    begin match a with
    | SEexpr(e) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"SEexpr\nlin:%d col:%d\",color=darkseagreen1,style=filled]\n" s (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s;
    print_expr s e
    end
    | SEident(chaine) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"SEident \\\"%s\\\"\nlin:%d col:%d\",color=darkseagreen1,style=filled]\n" s chaine (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s
    end
    | SEconst(const) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"SEconst\nlin:%d col:%d\",color=darkseagreen1,style=filled]\n" s (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s;
    print_const s const
    end
    | SEblock(liste) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"[SEblock]\nlin:%d col:%d\",color=darkseagreen1,style=filled]\n" s (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s;
    print_block s liste
    end
    
    end ;
  print_atomiclist pere b end

and print_block pere liste = 
  match liste with
  |[] -> ()
  |a::b -> begin print_expr pere a; print_block pere b end

and print_expr pere ({desc=e; loc=localisation}:Ast.expr) =
  match e with
  |Eatomiclist(li) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Eatomiclist\nlin:%d col:%d\",color=green,style=filled]\n" s (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s;
    print_atomiclist s li
    end
  | Elambda({desc={formalslambda=liste;	bodylambda=expr;};loc=llbis}) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Elambda\nlin:%d col:%d\",color=green,style=filled]\n" s (loclin llbis) (loccol llbis);
    printf "%s -> %s\n" pere s;
    print_formals s liste;
    print_expr s expr
    end
  | Ebinop(opp,e1,e2) ->let {descb=op;loc=llbis} = opp in let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Eop %s\nlin:%d col:%d\",color=green4,style=filled]\n" s (identifier_operande op) (loclin llbis) (loccol llbis);
    printf "%s -> %s\n" pere s;
    print_expr s e1;
    print_expr s e2
    end
  | Eif(cond, e1, e2) ->  let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Eif\nlin:%d col:%d\",color=green,style=filled]\n" s (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s;
    print_expr s cond;
    print_expr s e1;
    print_expr s e2
    end
  | Elet(liste, expr) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Elet\nlin:%d col:%d\",color=green,style=filled]\n" s (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s;
    print_deflist s liste;
    print_expr s expr
    end
  | Ecase(expr, vide, id1,id2,expr2) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Ecase\nlin:%d col:%d\",color=green,style=filled]\n" s (loclin localisation) (loccol localisation);
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
  | Edo(liste) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Edo\nlin:%d col:%d\",color=green,style=filled]\n" s (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s;
    print_block s liste
    end
  | Ereturn -> let s = (string_of_int !i) in begin
    i:= !i+1;
    printf "%s [label=\"Ereturn\nlin:%d col:%d\",color=greenyellow,style=filled]\n" s (loclin localisation) (loccol localisation);
    printf "%s -> %s\n" pere s;
    end

and print_formals pere f =
    match f with
    |[] -> ()
    |a::b -> let s = (string_of_int !i) in
      begin
      i := !i +1;
      printf "%s [label=\"arg %s\",color=orange,style=filled]\n" s a;
      printf "%s -> %s\n" pere s;
      print_formals pere b
      end

and print_deflist pere (liste:Ast.def list) =
  match liste with
  |[] -> ()
  |hh::b -> let ({desc={gauche = a; formals = f; body = e};loc=localisation}:Ast.def) = hh in begin let s = (string_of_int !i)in 
  i := !i +1;
  printf "%s [label=\"%s\nlin:%d col:%d\",color=crimson, style=filled]\n" s a (loclin localisation) (loccol localisation);
  printf "%s -> %s\n" pere s;
  print_formals s f;
  print_expr s e;
  print_deflist pere b
  end



let print_def0 ({desc=description;loc=localisation}:def0) =
  let {gauche0 = a; formals0 = f; body0 = e} = description in
  begin let s = (string_of_int !i)in 
  i := !i +1;
  printf "%s [label=\"%s\nlin:%d col:%d\",color=red, style=filled]\n" s a (loclin localisation) (loccol localisation);
  print_formals s f;
  print_expr s e;
  end

let rec print_prog prog =
  match prog with
  |[] -> ()
  |a::b -> begin
    print_def0 a;
    print_prog b
  end

let print_fichier {desc=description;loc=localisation} =
  let {defs = prog} = description in
  begin
  printf "digraph G {\nnode [shape=box]\n";
  print_prog prog;
  printf "\n}\n";
  end
  

