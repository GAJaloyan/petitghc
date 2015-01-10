open Ast

exception Typing_error of Ast.loc*string

type typ =
  | Tbool
  | Tchar
  | Tint
  | Tunit
  | Tarrow of typ * typ
  | Tlist of typ
  | Tvar of tvar

and tvar =
  { id : int;
    mutable def : typ option }
   
(* module V pour les variables de type *)
module V = struct
  type t = tvar
  let compare v1 v2 = Pervasives.compare v1.id v2.id
  let equal v1 v2 = v1.id = v2.id
  let create = let r = ref 0 in fun () -> incr r; { id = !r; def = None }
end
 
(*réduction en tête*)
let rec head t:typ =
    match t with
    |Tvar {def = Some t} -> head t
    |t -> t

let rec canon t:typ=
  match head t with
  |Tvar _  as t -> t
  |Tbool as t -> t
  |Tchar as t -> t
  |Tint as t -> t
  |Tunit as t -> t
  |Tarrow(a,b) -> Tarrow(canon a, canon b)
  |Tlist (a) -> Tlist(canon a)
  
(* tests *)
let rec printtyp fmt = function
  | Tint -> Format.fprintf fmt "int"
  | Tbool -> Format.fprintf fmt "bool"
  | Tchar -> Format.fprintf fmt "char"
  | Tunit -> Format.fprintf fmt "unit"
  | Tarrow (ty1, ty2) -> Format.fprintf fmt "(%a -> %a)" printtyp ty1 printtyp ty2
  | Tlist (a) -> Format.fprintf fmt "%a list" printtyp a
  | Tvar v -> print_tvar fmt v
and print_tvar fmt v =
  Format.fprintf fmt "'%d" v.id;
  match v.def with None -> () | Some ty -> Format.fprintf fmt "[:=%a]" printtyp ty

let print typ =
  printtyp (Format.std_formatter) (canon typ); Format.fprintf (Format.std_formatter) "\n"
   

  
(*Unification*)
exception UnificationFailure of typ * typ

let unification_error t1 t2 = raise (UnificationFailure (canon t1, canon t2))

let rec occur v t = match head t with
  | Tvar w -> V.equal v w
  | Tint | Tbool | Tchar | Tunit -> false
  | Tarrow (t1, t2) -> occur v t1 || occur v t2
  | Tlist(t) -> occur v t
  
let rec unify t1 t2 = match head t1, head t2 with
  | Tint, Tint -> ()
  | Tbool, Tbool -> ()
  | Tchar, Tchar -> ()
  | Tunit, Tunit -> ()
  | Tvar v1, Tvar v2 when V.equal v1 v2 -> ()
  | Tvar v1 as t1, t2 ->
      if occur v1 t2 then unification_error t1 t2;
      assert (v1.def = None);
      v1.def <- Some t2
  | t1, Tvar v2 ->
      unify t2 t1
  | Tarrow (t11, t12), Tarrow (t21, t22) -> unify t11 t21; unify t12 t22
  | Tlist(a), Tlist(b) -> unify a b
  | t1, t2 ->
      unification_error t1 t2

(* tests*)

let () =
  let a = V.create () in
  let b = V.create () in
  let ta = Tvar a in
  let tb = Tvar b in
  assert (occur a ta);
  assert (occur b tb);
  assert (not (occur a tb));
  let ty = Tarrow (ta, tb) in
  assert (occur a ty);
  assert (occur b ty);
  (* unifie 'a-> 'b et int->int *)
  unify ty (Tarrow (Tint, Tint));
  assert (canon ta = Tint);
  assert (canon ty = Tarrow (Tint, Tint));
  (* unifie 'c et int->int *)
  let c = V.create () in
  let tc = Tvar c in
  unify tc ty;
  assert (canon tc = Tarrow (Tint, Tint))

let cant_unify ty1 ty2 =
  try let _ = unify ty1 ty2 in false with UnificationFailure _ -> true

let () =
  assert (cant_unify Tint (Tarrow (Tint, Tint)));
  assert (cant_unify Tint (Tarrow (Tint, Tint)));
  let a = V.create () in
  let ta = Tvar a in
  unify ta (Tarrow (Tint, Tint));
  assert (cant_unify ta Tint)



(* schéma de type *)

module Vset = Set.Make(V)

type schema = { vars : Vset.t; typ : typ }

(* variables libres *)

let rec fvars t = match head t with
  | Tint | Tchar |Tbool |Tunit -> Vset.empty
  | Tarrow (t1, t2) -> Vset.union (fvars t1) (fvars t2)
  | Tlist(a) -> fvars a
  | Tvar v -> Vset.singleton v

let norm_varset s =
  Vset.fold (fun v s -> Vset.union (fvars (Tvar v)) s) s Vset.empty

let () =
  assert (Vset.is_empty (fvars (Tarrow (Tint, Tint))));
  let a = V.create () in
  let ta = Tvar a in
  let ty = Tarrow (ta, ta) in
  assert (Vset.equal (fvars ty) (Vset.singleton a));
  unify ty (Tarrow (Tint, Tint));
  assert (Vset.is_empty (fvars ty))

(* environnement c'est une table bindings (string -> schema),
   et un ensemble de variables de types libres *)

module Smap = Map.Make(String)

type env = { bindings : schema Smap.t; fvars : Vset.t }

let empty = { bindings = Smap.empty; fvars = Vset.empty }

let add gen x t env =
  let vt = fvars t in
  let s, fvars =
    if gen then
      let env_fvars = norm_varset env.fvars in
      { vars = Vset.diff vt env_fvars; typ = t }, env.fvars
    else
      { vars = Vset.empty; typ = t }, Vset.union env.fvars vt
  in
  { bindings = Smap.add x s env.bindings; fvars = fvars }

module Vmap = Map.Make(V)


let find x env =
  let tx = Smap.find x env.bindings in
  let s =
    Vset.fold (fun v s -> Vmap.add v (Tvar (V.create ())) s)
      tx.vars Vmap.empty
  in
  let rec subst t = match head t with
    | Tvar x as t -> (try Vmap.find x s with Not_found -> t)
    | Tint -> Tint
    | Tchar -> Tchar
    | Tbool -> Tbool
    | Tunit -> Tunit
    | Tarrow (t1, t2) -> Tarrow (subst t1, subst t2)
    | Tlist (a) -> Tlist (subst a)
  in
  subst tx.typ













type tbinop = 
{
  tdescb: tbinopd;
  typ:typ;
}
and tbinopd = Add | Sub | Mul | Infe | Supe | Infs | Sups | Uneq | Eq | And | Or | Head

type tsimple_expr = 
{
  desc: tsimple_exprd;
  typ:typ;
}
and tsimple_exprd =
  | SEexpr  of texpr
  | SEident of string
  | SEconst of tconst
  | SEblock of texpr list


and texpr =
{
  desc: texprd;
  typ:typ;
}
and texprd =
  | Eatomiclist of tsimple_expr list
  | Elambda of tlambda
  | Ebinop of tbinop * texpr * texpr
  | Eif of texpr*texpr*texpr
  | Elet of (tdef list)*(texpr)
  | Ecase of texpr*texpr*string*string*texpr
  | Edo of texpr list
  | Ereturn

and tconst = 
{
  desc:tconstd;
  typ:typ;
}
and tconstd = 
	|Ctrue
	|Cfalse
	|Cint of int
	|Cchar of char
	|Cstring of char list

and tlambda =
{
  desc:tlambdad;
  typ:typ;
}
and tlambdad =
	{
		formalslambda : string list; (*ident1*)
		bodylambda : texpr; 
	}
and tdef =
{
  desc:tdefd;
  typ:typ;
}
and tdefd =
{
	gauche    : string;    (*ident1*)
  formals : string list; (* arguments : ident1*)
  body    : texpr; 
}

type tdef0 =
{
  desc:tdef0d;
  typ:typ;
}
and tdef0d =
{
	gauche0  : string;    (*ident0*)
  formals0 : string list; (* arguments : ident1*)
  body0    : texpr; 
}

type tprogram =
{
  desc:tprogramd;
  typ:typ;
}
and tprogramd =
	{
  defs : tdef0 list;
  }
  
let typtostr t = printtyp (Format.str_formatter) t; Format.flush_str_formatter () 

(*types : 
| Tbool
  | Tchar
  | Tint
  | Tunit
  | Tarrow of typ * typ
  | Tlist of typ
  | Tvar of tvar*)

module SS = Set.Make(String)

let wpasdedoublon (l:string list) (ll:Ast.loc) =
  let dejaVu = ref SS.empty in
  let rec aux (l:string list) =
    match l with
    |[] -> ()
    |a::b -> (if (SS.mem a !dejaVu) then raise (Typing_error (ll,"parameter \""^ a ^"\" is defined several times." )) 
          else  dejaVu := (SS.add a !dejaVu));
          aux b
  in aux l

      
let rec transformerlambda expr =
  let ({desc=Elambda({desc=({formalslambda=liste;bodylambda=exp}:Ast.lambdad);loc=lll}:Ast.lambda);loc=ll}:Ast.expr) = expr in
  match liste with
  |[] -> failwith "crash degueulasse qui n'était pas censé arriver"
  |a::[] -> expr
  |a::b -> let traexpr = transformerlambda ({desc=Elambda({desc=({formalslambda=b;bodylambda=exp}:Ast.lambdad);loc=lll}:Ast.lambda);loc=ll}:Ast.expr) in 
        {desc=Elambda({desc=({formalslambda=[a];bodylambda=traexpr}:Ast.lambdad);loc=lll}:Ast.lambda);loc=ll}


let wconst env (cons:Ast.const) : tconst = 
  match cons.desc with
  |Ctrue -> {desc=Ctrue;typ=Tbool}
	|Cfalse -> {desc=Cfalse;typ=Tbool}
	|Cint (a) -> {desc=Cint (a);typ=Tint}
	|Cchar (c) -> {desc=Cchar (c);typ=Tchar}
	|Cstring (l) -> {desc=Cstring (l);typ=Tlist(Tchar)}

let rec verifierListe (l1:Ast.expr list) (l2:texpr list) typvoulu : unit =
  match l2 with
  | [] -> ()
  | a::b -> (try (unify a.typ typvoulu) with 
              |_ -> raise (Typing_error ((List.hd l1).loc,"this expression has type "^ (typtostr a.typ) ^ " while type " ^(typtostr typvoulu)^ " was expected.")));
            verifierListe (List.tl l1) b typvoulu
            
let wtesterletliste (liste:Ast.def list) env =
  let dejaVu = ref SS.empty in
  let rec aux (liste:Ast.def list) env =
  match liste with
  |[] -> env
  |({desc=({gauche=nom;formals=_;body=_}:Ast.defd);loc=localisation}:Ast.def)::b -> 
    begin
        (if (SS.mem nom !dejaVu) then raise (Typing_error (localisation,"variable \""^ nom ^ "\" is defined several times." )) 
          else  dejaVu := (SS.add nom !dejaVu));
          let v = Tvar(V.create ()) in
          let env = (add true nom (v) env) in
          aux b env
    end
  in
  aux liste env
  

let rec wsexprlist env (sexprliste : Ast.simple_expr list) : ((tsimple_expr list)*typ) =
  match sexprliste with
  |[] -> [],Tunit
  |a::[] -> let ta = wsexpr env a in [ta],ta.typ
  |a::b -> let ta = wsexpr env a in   (*type t1 -> t2*)
           let tb,typp = wsexprlist env b in (*typp type t1*)
           let v = Tvar (V.create ()) in
           begin
            (try (unify ta.typ (Tarrow (typp, v))) with |_ -> raise (Typing_error (a.loc,"the expression e1 e2 has type "^(typtostr (Tarrow (typp, v)))^" while type "^(typtostr ta.typ)^" was expected.")));
            (ta::tb, v)
            (*type t2*)
           end

and wtyperlesei (liste:Ast.def list) env =
  match liste with
  |[] -> [], env
  |({desc=({gauche=nom;formals=_;body=expri}:Ast.defd);loc=localisation}:Ast.def)::b -> 
    let texpri = wexpr env expri in let te = texpri.typ in
    begin
      let tt = find nom env in (unify tt te); 
      let x,y = (wtyperlesei b env) in
      ({desc=({gauche=nom;formals=[];body=texpri}:tdefd);typ=te}:tdef)::x,y
    end

and wsexpr env (sexpr:Ast.simple_expr) : tsimple_expr =
  match sexpr.desc with
  |SEexpr (e) -> let te = wexpr env e in {desc=SEexpr(te);typ=te.typ}
  |SEconst (c) -> let tc = wconst env c in {desc=SEconst(tc); typ = tc.typ}
  |SEident (s) -> let ts = find s env in {desc=SEident(s); typ = ts}
  |SEblock (liste) -> let tliste, typliste = wliste env liste in {desc=SEblock(tliste);typ =Tlist(typliste)}

and wliste env (liste:Ast.expr list) : (texpr list*typ) = 
  match liste with
  |[] -> let v = Tvar(V.create ()) in [],v
  |a::[] -> let ta = wexpr env a in [ta], ta.typ
  |a::q -> let tq, typq = wliste env q in 
      let ta = wexpr env a in
      begin
        (try (unify ta.typ typq) with 
              |_ -> raise (Typing_error (a.loc,"this element has type "^ (typtostr ta.typ)^ " while the list has type "^(typtostr typq)^ " .")));
        ta::tq,typq
      end

and wexpr env (expr : Ast.expr) : texpr = 
  let localisation = expr.loc in 
  match expr.desc with
  |Eatomiclist (liste) -> let (tliste, typfinal) = wsexprlist env liste in
              {desc=Eatomiclist(tliste);typ=typfinal}
  |Ecase(e1,e2,x1,x2,e3) -> 
  if ((String.compare x1 x2) = 0) 
    then raise (Typing_error (localisation,"case construction invalid (x1 and x2 have to be different in case _ of {_; x1:x2 -> _})."))
    else 
    let te1 = (wexpr env e1) in let t1 = te1.typ in
    let te2 = (wexpr env e2) in let t2 = te2.typ in
    let v = Tvar(V.create ()) in 
    begin
      (try (unify t1 (Tlist(v))) with |_ -> raise (Typing_error (e1.loc,"case e1 of : e1 is of type "^(typtostr t1)^" while type 'a list was expected.")));
      let env = (add false x1 (v) env) in
      let env = (add false x2 (Tlist(v)) env) in
      let te3 = wexpr env e3 in let t3 = te3.typ in
      begin
        (try (unify t2 t3) with |_ -> raise (Typing_error (localisation,"case _ of {_ -> e2; _ -> e3} : e2 has type " ^(typtostr t2)^ " and e3 has type "^(typtostr t3)^" :unable to unify both types.")));
        {desc=Ecase(te1,te2,x1,x2,te3);typ=t2}
      end
    end
  
  | Ebinop (operateur, gauche, droite) -> 
      let tgauche = wexpr env gauche in let tg= tgauche.typ in
      let tdroite = wexpr env droite in let td= tdroite.typ in 
      begin
        match operateur.descb with
        |And -> 
        begin 
          (try (unify tg Tbool) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 && _ avec Tbool.")));
          (try (unify td Tbool) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ && e2 avec Tbool.")));
          {desc=Ebinop(({tdescb=And;typ=Tbool}:tbinop),tgauche,tdroite);typ=Tbool}
        end
        |Or -> 
        begin 
          (try (unify tg Tbool) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 || _ avec Tbool.")));
          (try (unify td Tbool) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ || e2 avec Tbool.")));
          {desc=Ebinop({tdescb=Or;typ=Tbool},tgauche,tdroite);typ=Tbool}
        end
        |Infe ->
        begin 
          (try (unify tg Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 <= _ avec Tint.")));
          (try (unify td Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ <= e2 avec Tint.")));
          {desc=Ebinop({tdescb=Infe;typ=Tbool},tgauche,tdroite);typ=Tbool}
        end
        |Supe ->
        begin 
          (try (unify tg Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 >= _ avec Tint.")));
          (try (unify td Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ >= e2 avec Tint.")));
          {desc=Ebinop({tdescb=Supe;typ=Tbool},tgauche,tdroite);typ=Tbool}
        end
        |Infs ->
        begin 
          (try (unify tg Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 < _ avec Tint.")));
          (try (unify td Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ < e2 avec Tint.")));
          {desc=Ebinop({tdescb=Infs;typ=Tbool},tgauche,tdroite);typ=Tbool}
        end
        |Sups ->
        begin 
          (try (unify tg Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 > _ avec Tint.")));
          (try (unify td Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ > e2 avec Tint.")));
          {desc=Ebinop({tdescb=Sups;typ=Tbool},tgauche,tdroite);typ=Tbool}
        end
        |Eq ->
        begin 
          (try (unify tg Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 == _ avec Tint.")));
          (try (unify td Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ == e2 avec Tint.")));
          {desc=Ebinop({tdescb=Eq;typ=Tbool},tgauche,tdroite);typ=Tbool}
        end
        |Uneq ->
        begin 
          (try (unify tg Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 /= _ avec Tint.")));
          (try (unify td Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ /= e2 avec Tint.")));
          {desc=Ebinop({tdescb=Uneq;typ=Tbool},tgauche,tdroite);typ=Tbool}
        end
        
        |Add ->
        begin 
          (try (unify tg Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 + _ avec Tint.")));
          (try (unify td Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ + e2 avec Tint.")));
          {desc=Ebinop({tdescb=Add;typ=Tint},tgauche,tdroite);typ=Tint}
        end
        |Sub ->
        begin 
          (try (unify tg Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 - _ avec Tint.")));
          (try (unify td Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ - e2 avec Tint.")));
          {desc=Ebinop({tdescb=Sub;typ=Tint},tgauche,tdroite);typ=Tint}
        end
        |Mul ->
        begin 
          (try (unify tg Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 * _ avec Tint.")));
          (try (unify td Tint) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression _ * e2 avec Tint.")));
          {desc=Ebinop({tdescb=Mul;typ=Tint},tgauche,tdroite);typ=Tint}
        end
        
        |Head ->
        begin 
          (try (unify (Tlist(tg)) td) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression e1 : e2 ---- [e1].typ != e2.typ")));
          {desc=Ebinop({tdescb=Head;typ=td},tgauche,tdroite);typ=td}
        end
        
        
      end
  | Eif (condition, sivrai, sifaux) -> 
      let tsivrai = wexpr env sivrai in let t1= tsivrai.typ in
      let tsifaux = wexpr env sifaux in let t2= tsifaux.typ in
      begin
        (try (unify t1 t2) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier la structure If(_,e1,e2).")));
        let tcond = wexpr env condition in let tc = tcond.typ in 
        begin
          try (unify tc Tbool) with |_ -> raise (Typing_error (localisation,"Impossible d'unifier l'expression If(cond, _, _) avec Tunit.")) 
        end;
        
        {desc=Eif(tcond, tsivrai, tsifaux); typ = t1}
      end
  | Edo liste -> let listeb = (List.map (wexpr env) liste) in 
                        begin
                          (verifierListe liste listeb Tunit);
                          {desc=Edo (listeb);typ=Tunit}
                        end
  | Ereturn -> {desc=Ereturn;typ=Tunit}
  
  | Elambda({desc=({formalslambda=liste;bodylambda=exp}:Ast.lambdad);loc=lll}:Ast.lambda) -> begin
    match liste with
    |[] -> failwith "crash degueulasse qui n'était pas censé arriver"
    |a::[] -> let v = Tvar (V.create ()) in
      let env = add false a v env in
      let texpr = wexpr env exp in let te = texpr.typ in
      {desc=Elambda({desc=({formalslambda=liste;bodylambda=texpr}:tlambdad);typ=Tarrow(v,te)}:tlambda);typ=Tarrow(v,te)}
    |a::b ->
    begin
      wpasdedoublon liste lll;
      let e = transformerlambda expr in wexpr env e
    end
   end
  | Elet (liste, ex) -> let env = wtesterletliste liste env in
      let tliste, env = wtyperlesei liste env in
      begin
        let tex = wexpr env ex in let tt = tex.typ in
        {desc=Elet(tliste, tex);typ=tt}
      end

let mainpresent = ref false


let wverifierliste (l:Ast.def0 list) env =
  let dejaVu = ref SS.empty in
  let rec aux (l:Ast.def0 list) env =
  match l with
  |[] -> env
  |{desc = a; loc = llinutile}::b -> let (nom, args, corps) = (a.gauche0,a.formals0,a.body0) in let v = Tvar (V.create ()) in
           let env = add false nom v env in 
        begin
          (if (SS.mem nom !dejaVu) then raise (Typing_error (llinutile,"Déclaration globale \""^ nom ^"\" définie précédemment dans le fichier." )) 
          else  dejaVu := (SS.add nom !dejaVu));
          
          (if((compare nom "main") = 0) then mainpresent := true else () );
          
          
          (if((compare nom "div") = 0) then raise (Typing_error (llinutile,"Nom de fonction illegal \"div\".")) else () );
          (if((compare nom "rem") = 0) then raise (Typing_error (llinutile,"Nom de fonction illegal \"rem\".")) else () );
          (if((compare nom "putChar") = 0) then raise (Typing_error (llinutile,"Nom de fonction illegal \"putChar\".")) else () );
          (if((compare nom "error") = 0) then raise (Typing_error (llinutile,"Nom de fonction illegal \"error\".")) else () );
          
          aux b env
        end
  in aux l env

let testerParametresFonction liste loca =
  let dejaVu = ref SS.empty in
    let rec aux l =
      match l with
      |[] -> ()
      |a::b -> if (SS.mem a !dejaVu) then raise (Typing_error (loca,"Deux paramètres de cette fonction ont même nom : \""^ a ^"\"." ))
              else 
                begin
                  dejaVu := (SS.add a !dejaVu);
                  aux b
                end
  in aux liste
    

let rec wtyperliste (l:Ast.def0 list) env : (tdef0 list * env) =
  match l with
  |[] -> [],env
  |({desc = a; loc = localisation}:Ast.def0)::b -> let (nom, args, corps) = (a.gauche0,a.formals0,a.body0) in 
    begin
            testerParametresFonction args localisation;
            let {desc=teted; typ=tetetyp}:tdef0 = wtyperunefonction nom args corps env in
            begin
              let tt = find nom env in (unify tt tetetyp);
              let reste,env2 = wtyperliste b env in 
              begin 
                (if((compare nom "main") = 0) then 
                      try (unify tetetyp Tunit)
                      with |_ -> raise (Typing_error (localisation,"Le main ne peut être unifié avec le type Tunit."))
                 else () );
                ({desc=teted; typ=tt}:tdef0)::reste,env 
              end
            end
    end
    
and wtyperunefonction nom args corps env :tdef0 =
      match args with
      |[] -> let ({desc=dexpr;typ=typ1}:texpr) = wexpr env corps in {desc={gauche0=nom;formals0=[];body0={desc=dexpr;typ=typ1}};typ=typ1}
      |h::t ->
              begin
                let v = Tvar(V.create ()) in
                let env = add false h v env in 
                let {desc=({gauche0=nom; formals0=argretour; body0=corpsretour}:tdef0d); typ = typ1}:tdef0 = wtyperunefonction nom t corps env in
                  let typearg = find h env in
                  ({desc={gauche0=nom;  formals0=h::argretour; body0=corpsretour};typ=(Tarrow(typearg,typ1))}:tdef0)
              end
    

let wprogram env ({desc=p;loc=llinutile}:Ast.program) = match p.defs with
  |liste(*Ast.def0 list*) -> let env = wverifierliste liste env in 
    let tliste,env = (wtyperliste liste env) in
    if(!mainpresent = false) then 
       raise (Typing_error (llinutile,"Le fichier n'a pas de main."))
    else
    {desc = {defs = tliste}; typ = Tunit}
  
let typeof (p:Ast.program) = 
  let v = Tvar(V.create ()) in
  let env = (add true "error" (Tarrow(Tlist(Tchar),v)) empty) in
  let env = (add false "putChar" (Tarrow(Tchar, Tunit)) env) in
  let env = (add false "rem" (Tarrow(Tint, Tarrow(Tint, Tint))) env) in
  let env = (add false "div" (Tarrow(Tint, Tarrow(Tint, Tint))) env) in
  wprogram env p
