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
  

val canon : typ -> typ
val typeof : Ast.program -> tprogram

