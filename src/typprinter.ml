open Typage 
open String
open Lexing
open Printf

let i = ref 0

let rec printtyp fmt = function
  | Tint -> Format.fprintf fmt "Tint"
  | Tbool -> Format.fprintf fmt "Tbool"
  | Tchar -> Format.fprintf fmt "Tchar"
  | Tunit -> Format.fprintf fmt "Tunit"
  | Tarrow (ty1, ty2) -> Format.fprintf fmt "(%a -> %a)" printtyp ty1 printtyp ty2
  | Tlist (a) -> Format.fprintf fmt "%a list" printtyp a
  | Tvar v -> print_tvar fmt v
and print_tvar fmt v =
  Format.fprintf fmt "'%d" v.id;
  match v.def with None -> () | Some ty -> Format.fprintf fmt "[:=%a]" printtyp ty

let printletype typ =
  printtyp (Format.std_formatter) (canon typ) (*Format.fprintf (Format.std_formatter) "\n"*)



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

let tprint_const pere ({desc=const;typ=ttt}:Typage.tconst) =
  match const with
  | Ctrue -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Ctrue\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=skyblue1,style=filled]\n";
    Format.printf "%s -> %s\n" pere s
    end
  | Cfalse -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Cfalse\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=skyblue1,style=filled]\n";
    Format.printf "%s -> %s\n" pere s
    end
  | Cint(a) ->let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Cint %d\ntyp:" s a;
    printletype ttt;
    Format.printf "\",color=skyblue1,style=filled]\n";
    Format.printf "%s -> %s\n" pere s
    end
  | Cchar(b) ->let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Cchar '%c'\ntyp:" s b;
    printletype ttt;
    Format.printf "\",color=skyblue1,style=filled]\n";
    Format.printf "%s -> %s\n" pere s
    end
  | Cstring(liste) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Cstring \\\"%s\\\"\ntyp:" s (string_implode liste);
    printletype ttt;
    Format.printf "\",color=skyblue1,style=filled]\n";
    Format.printf "%s -> %s\n" pere s
    end

let rec tprint_atomiclist pere (l:Typage.tsimple_expr list) =
  match l with
  |[] -> ()
  |(hh:Typage.tsimple_expr)::b -> let ({desc=a;typ=ttt}:Typage.tsimple_expr) = hh in begin 
    begin match a with
    | SEexpr(e) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"SEexpr\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=darkseagreen1,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    tprint_expr s e
    end
    | SEident(chaine) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"SEident \\\"%s\\\"\ntyp:" s chaine;
    printletype ttt;
    Format.printf "\",color=darkseagreen1,style=filled]\n";
    Format.printf "%s -> %s\n" pere s
    end
    | SEconst(const) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"SEconst\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=darkseagreen1,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    tprint_const s const
    end
    | SEblock(liste) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"[SEblock]\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=darkseagreen1,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    tprint_block s liste
    end
    
    end ;
  tprint_atomiclist pere b end

and tprint_block pere liste = 
  match liste with
  |[] -> ()
  |a::b -> begin tprint_expr pere a; tprint_block pere b end

and tprint_expr pere ({desc=e; typ=ttt}:Typage.texpr) =
  match e with
  | Eatomiclist(li) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Eatomiclist\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=green,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    tprint_atomiclist s li
    end
  | Elambda({desc={formalslambda=liste; bodylambda=expr;};typ=ttbis}) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Elambda\ntyp:" s;
    printletype ttbis;
    Format.printf "\",color=green,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    tprint_formals s liste;
    tprint_expr s expr
    end
  | Ebinop(opp,e1,e2) ->let {tdescb=op;typ=ttbis} = opp in let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Eop %s\ntyp:"  s (identifier_operande op);
    printletype ttbis;
    Format.printf "\",color=green4,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    tprint_expr s e1;
    tprint_expr s e2
    end
  | Eif(cond, e1, e2) ->  let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Eif\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=green,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    tprint_expr s cond;
    tprint_expr s e1;
    tprint_expr s e2
    end
  | Elet(liste, expr) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Elet\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=green,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    tprint_deflist s liste;
    tprint_expr s expr
    end
  | Ecase(expr, vide, id1,id2,expr2) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Ecase\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=green,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    tprint_expr s expr;
    let s2 = (string_of_int !i) in begin
      i:= !i+1;
      Format.printf "%s [label=\"[]\",color=gold,style=filled]\n" s2;
      Format.printf "%s -> %s\n" s s2;
      tprint_expr s2 vide;end; 
    
      let s2 = (string_of_int !i) in begin
      i:= !i+1;
      Format.printf "%s [label=\"%s:%s\",color=gold,style=filled]\n" s2 id1 id2;
      Format.printf "%s -> %s\n" s s2;
      tprint_expr s2 expr2;end
    end
  | Edo(liste) -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Edo\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=green,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    tprint_block s liste
    end
  | Ereturn -> let s = (string_of_int !i) in begin
    i:= !i+1;
    Format.printf "%s [label=\"Ereturn\ntyp:" s;
    printletype ttt;
    Format.printf "\",color=greenyellow,style=filled]\n";
    Format.printf "%s -> %s\n" pere s;
    end

and tprint_formals pere f =
    match f with
    |[] -> ()
    |a::b -> let s = (string_of_int !i) in
      begin
      i := !i +1;
      Format.printf "%s [label=\"arg %s\",color=orange,style=filled]\n" s a;
      Format.printf "%s -> %s\n" pere s;
      tprint_formals pere b
      end

and tprint_deflist pere (liste:Typage.tdef list) =
  match liste with
  | [] -> ()
  | hh::b -> 
     let ({desc={gauche = a; formals = f; body = e};typ=ttt}:Typage.tdef) = hh 
     in begin let s = (string_of_int !i)in 
        i := !i +1;
        Format.printf "%s [label=\"%s\ntyp:" s a;
        printletype ttt;
        Format.printf "\",color=crimson, style=filled]\n";
        Format.printf "%s -> %s\n" pere s;
        tprint_formals s f;
        tprint_expr s e;
        tprint_deflist pere b
     end



let tprint_def0 ({desc=description;typ=ttt}:Typage.tdef0) =
  let {gauche0 = a; formals0 = f; body0 = e} = description in
  begin let s = (string_of_int !i)in 
    i := !i +1;
    Format.printf "%s [label=\"%s\ntyp: " s a; 
    printletype ttt;
    Format.printf "\",color=red, style=filled]\n";
    tprint_formals s f;
    tprint_expr s e;
  end

let rec tprint_prog prog =
  match prog with
  |[] -> ()
  |a::b -> begin
    tprint_def0 a;
    tprint_prog b
  end

let tprint_fichier {desc=description;typ=ttt} =
  let {defs = prog} = description in
    begin
    Format.printf "digraph G {\nnode [shape=box]\n";
    tprint_prog prog;
    Format.printf "\n}\n";
  end
  

