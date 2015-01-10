
/* Analyseur syntaxique pour petit-Haskell */

%{
  open Ast
  
  
  let auxiliaire (a:Ast.simple_expr) (b:Ast.simple_expr) : Ast.simple_expr =
      {desc=SEexpr({desc=Eatomiclist(a::b::[]);loc=a.loc}:Ast.expr);loc=a.loc}
  
  
  let transformee (l:Ast.simple_expr list) = match l with
    |[] -> []
    |a::[] -> [a]
    |a::b -> [List.fold_left (auxiliaire) (a) b]
    
%}

/* Déclaration des tokens */

%token EOF
%token <int> INTEGER
%token <char> VCHAR
%token <char list> VSTRING
%token <string> IDENT0
%token <string> IDENT1
%token VTRUE VFALSE


%token IN


%token ELSE
%nonassoc ELSE IN FLECHE

%token IF LET CASE OF THEN RETURN DO

%token FLECHE

%token COMMA COLON
%right COLON

%token OUOU
%left OUOU

%token ETET
%left ETET

%token Smaller SmallerEqual Greater GreaterEqual EGAL NotEqual
%left Smaller SmallerEqual Greater GreaterEqual EGAL NotEqual

%token PVACC SEMICOLON


%token PLUS MOINS
%left PLUS MOINS

%token MULT
%left MULT

%token BACKSLASH
%token LPAR RPAR
%token LBRA RBRA
%token LCBR RCBR


/* Point d'entrée de la grammaire */
%start fichier
%type <Ast.program> fichier
%type <Ast.def0> def0
%type <Ast.def> def
%type <Ast.const> const
%type <Ast.simple_expr> simple_expr
%type <Ast.def list> liaisons
%type <Ast.expr> expr

%%

fichier:
	|d = def0* EOF{ {desc = { defs = d} ; loc = $startpos,$endpos} }
;

def0:
  
	|i0 = IDENT0 i1 = IDENT1+ EGAL e = expr 
	{  
	  {desc = 
	    {gauche0 = i0; formals0 = []; body0 =
	        ({desc=Elambda({desc=({formalslambda=i1;bodylambda=e}:Ast.lambdad);loc=$startpos,$endpos}:Ast.lambda);loc=$startpos,$endpos}:Ast.expr) 
	    } 
	  ; loc = $startpos,$endpos}  
	}
	|i0 = IDENT0 EGAL e = expr
	{
	  {desc=
	    {gauche0=i0;formals0=[];body0=
	      (e:Ast.expr)
	    };
	  loc=$startpos,$endpos}
	}
;

def:
	|i0 = IDENT1 i1 = IDENT1+ EGAL e = expr 
	{  
	  {desc = 
	    {gauche = i0; formals = []; body =
	        ({desc=Elambda({desc=({formalslambda=i1;bodylambda=e}:Ast.lambdad);loc=$startpos,$endpos}:Ast.lambda);loc=$startpos,$endpos}:Ast.expr) 
	    }; 
	  loc = $startpos,$endpos}  
	}
	|i0 = IDENT1 EGAL e = expr
	{
	  {desc=
	    {gauche=i0;formals=[];body=
	      (e:Ast.expr)
	    };
	  loc=$startpos,$endpos}
	}
;



const:
	|VTRUE { {desc = Ctrue ; loc = $startpos,$endpos}  }
	|VFALSE { {desc = Cfalse ; loc = $startpos,$endpos}  }
	|i = INTEGER { {desc = Cint (i) ; loc = $startpos,$endpos}  }
	|c= VCHAR { {desc = Cchar (c) ; loc = $startpos,$endpos}  }
	|s = VSTRING { {desc = Cstring (s) ; loc = $startpos,$endpos}  }
;

simple_expr:
	|LPAR e1 = expr RPAR { {desc = SEexpr (e1) ; loc = $startpos,$endpos}  }
	|s1 = IDENT1 { {desc = SEident (s1) ; loc = $startpos,$endpos}  }
	|c = const { {desc = SEconst (c) ; loc = $startpos,$endpos}  }
	|LBRA e1 = separated_list (COMMA,expr) RBRA { {desc = SEblock (e1) ; loc = $startpos,$endpos}  }
;

%inline op:
	|PLUS { {descb = Add ; loc = $startpos,$endpos} }
	|MOINS{ {descb = Sub ; loc = $startpos,$endpos} }
	|MULT { {descb = Mul ; loc = $startpos,$endpos} }
	|SmallerEqual { {descb = Infe ; loc = $startpos,$endpos} }
	|GreaterEqual { {descb = Supe ; loc = $startpos,$endpos} }
	|Smaller { {descb = Infs ; loc = $startpos,$endpos} }
	|Greater { {descb = Sups ; loc = $startpos,$endpos} }
	|NotEqual { {descb = Uneq ; loc = $startpos,$endpos} }
	|EGAL EGAL { {descb = Eq ; loc = $startpos,$endpos} }
	|ETET { {descb = And ; loc = $startpos,$endpos} }
	|OUOU { {descb = Or ; loc = $startpos,$endpos} }
	|COLON { {descb = Head ; loc = $startpos,$endpos} }
;

liaisons:
	|d=def {[d]}
	|LCBR e = separated_nonempty_list(SEMICOLON, def) PVACC {e}
	|LCBR e = separated_nonempty_list(SEMICOLON, def) RCBR {e}
;

expr:
	|e1 = expr ope=op e2=expr { {desc = Ebinop(ope, e1, e2); loc = $startpos,$endpos} }
	|MOINS e1 = expr 
	{ 
	  {desc = Ebinop ({descb = Sub ; loc = $startpos,$endpos}, 
	                  {desc = Eatomiclist [{desc = SEconst {desc = (Cint 0) ; loc = $startpos,$endpos} ; loc = $startpos,$endpos}]; loc = $startpos,$endpos}, 
	                  e1); 
	  loc = $startpos,$endpos} 
	}
	
	|s = simple_expr+ { {desc = Eatomiclist (transformee(s)); loc = $startpos,$endpos} }
	|BACKSLASH i = nonempty_list(IDENT1) FLECHE e = expr { {desc = Elambda {desc = {formalslambda = i; bodylambda = e}; loc = $startpos,$endpos} ; loc = $startpos,$endpos} }
	|IF e1 = expr THEN e2 = expr ELSE e3=expr { {desc = Eif(e1, e2, e3); loc = $startpos,$endpos} }
	|LET l = liaisons IN e = expr { {desc = Elet(l,e); loc = $startpos,$endpos} }
	
	|CASE e= expr OF LCBR LBRA RBRA FLECHE e1 = expr SEMICOLON i1 = IDENT1 COLON i2 = IDENT1 FLECHE e2 = expr RCBR { {desc = Ecase(e,e1,i1,i2,e2); loc = $startpos,$endpos} }
	|CASE e= expr OF LCBR LBRA RBRA FLECHE e1 = expr SEMICOLON i1 = IDENT1 COLON i2 = IDENT1 FLECHE e2 = expr PVACC { {desc = Ecase(e,e1,i1,i2,e2); loc = $startpos,$endpos} }
	
	|DO e = delimited(LCBR,separated_nonempty_list(SEMICOLON, expr),RCBR) { {desc = Edo(e); loc = $startpos,$endpos} }
	|DO e = delimited(LCBR,separated_nonempty_list(SEMICOLON, expr),PVACC) { {desc = Edo(e); loc = $startpos,$endpos} }
	
	|RETURN LPAR RPAR { {desc = Ereturn; loc = $startpos,$endpos} }
	
;

