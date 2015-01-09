type loc = Lexing.position

exception ErrorUndef of loc*string 

type binop = 
{
  descb: binopd;
  loc:loc;
}
and binopd = Add | Sub | Mul | Infe | Supe | Infs | Sups | Uneq | Eq | And | Or | Head

type simple_expr = 
{
  desc: simple_exprd;
  loc:loc;
}
and simple_exprd =
  | SEexpr  of expr
  | SEident of string
  | SEconst of const
  | SEblock of expr list


and expr =
{
  desc: exprd;
  loc:loc;
}
and exprd =
  | Eatomiclist of simple_expr list
  | Elambda of lambda
  | Ebinop of binop * expr * expr
  | Eif of expr*expr*expr
  | Elet of (def list)*(expr)
  | Ecase of expr*expr*string*string*expr
  | Edo of expr list
  | Ereturn

and const = 
{
  desc:constd;
  loc:loc;
}
and constd = 
	|Ctrue
	|Cfalse
	|Cint of int
	|Cchar of char
	|Cstring of char list

and lambda =
{
  desc:lambdad;
  loc:loc;
}
and lambdad =
	{
		formalslambda : string list; (*ident1*)
		bodylambda : expr; 
	}
and def =
{
  desc:defd;
  loc:loc;
}
and defd =
{
	gauche    : string;    (*ident1*)
  formals : string list; (* arguments : ident1*)
  body    : expr; 
}

type def0 =
{
  desc:def0d;
  loc:loc;
}
and def0d =
{
	gauche0  : string;    (*ident0*)
  formals0 : string list; (* arguments : ident1*)
  body0    : expr; 
}

type program =
{
  desc:programd;
  loc:loc;
}
and programd =
	{
  defs : def0 list;
  }
  
  
