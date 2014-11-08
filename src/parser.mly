%token Eof
%token If Then Else
%token Assign
%token LeftCurly RightCurly LeftBracket RightBracket LeftPar RightPar
%token Plus Minus Time
%token Greater GreaterEq Lower LowerEq Unequal Equal
%token And Or
%token Colon
%token Return
%token Do
%token Case
%token Of
%token True False
%token Comma
%token Lambda
%token Arrow
%token Semicolon
%token Let
%token In
%token <int> Int
%token <string> Ident
%token <string> Ident0
%token <char> Char
%token <string> String

%nonassoc In Lambda
%nonassoc Else
%left Or
%left And
%left Plus Minus
%right Colon
%nonassoc Greater GreaterEq Lower LowerEq Unequal Equal
%left Time
%nonassoc neg

%start <Ast.file> file
%%

file:
    | Eof { [] }
    | d = def0 ds = file { d :: ds }

def0:
    | i = Ident0 is = identList e = expression { (i,is,e) }
    
def:
    | i = Ident is = identList e = expression { (i,is,e) }

simple_expr:
    | LeftPar e = expression RightPar { Ast.Par e }
    | i = Ident                       { Ast.Id i }
    | c = const                       { Ast.Cst c }
    | RightBracket l = eList           { Ast.List l }

list_simple_expr:
    | s = simple_expr l = list_simple_expr { s :: l }
    | s = simple_expr { [s] }

eList:
    | e = expression Comma l = eList { e :: l }
    | e = expression LeftBracket    { [e] }
    | LeftBracket                   { [] }

expression:
    | e = list_simple_expr { Ast.Simple e }
    | Lambda s = param e = expression { Ast.Lambda (s,e) }
    | Minus e = expression { Ast.Neg e } %prec neg
    | e1 = expression Plus e2 = expression { Ast.BinOp (e1,Ast.Plus,e2) }
    | e1 = expression Minus e2 = expression { Ast.BinOp (e1,Ast.Minus,e2) }
    | e1 = expression Time e2 = expression { Ast.BinOp (e1,Ast.Time,e2) }
    | e1 = expression Greater e2 = expression { Ast.BinOp (e1,Ast.Greater,e2) }
    | e1 = expression GreaterEq e2 = expression { Ast.BinOp (e1,Ast.GreaterEq,e2) }
    | e1 = expression Lower e2 = expression { Ast.BinOp (e1,Ast.Lower,e2) }
    | e1 = expression LowerEq e2 = expression { Ast.BinOp (e1,Ast.LowerEq,e2) }
    | e1 = expression Unequal e2 = expression { Ast.BinOp (e1,Ast.Unequal,e2) }
    | e1 = expression Equal e2 = expression { Ast.BinOp (e1,Ast.Equal,e2) }
    | e1 = expression Colon e2 = expression { Ast.BinOp (e1,Ast.Colon,e2) }
    | e1 = expression Or e2 = expression { Ast.BinOp (e1,Ast.Or,e2) }
    | e1 = expression And e2 = expression { Ast.BinOp (e1,Ast.And,e2) }
    | If e1 = expression Then e2 = expression Else e3 = expression { Ast.If (e1,e2,e3) }
    | Let b = bindings In e = expression { Ast.Let (b,e) }
    | Case e1 = expression Of LeftCurly LeftBracket RightBracket Arrow e2 = expression Semicolon i = Ident Colon is = Ident Arrow e3 = expression Semicolon? RightCurly { Ast.Case (e1,e2,i,is,e3) }
    | Do LeftCurly l = toDo { Ast.Do l }
    | Return LeftPar RightPar { Ast.Return }

toDo:
    | d = expression Semicolon? RightCurly { [] }
    | d = expression Semicolon l = toDo { d :: l }

identList:
    | i = Ident l = identList { i :: l }
    | Assign { [] }

param:
    | i = Ident p = param { i :: p }
    | i = Ident Arrow { [i] }

bindings:
    | d = def { Ast.Def d }
    | LeftBracket l = listBindings { Ast.ListDef l }

listBindings:
    | Semicolon? LeftBracket { [] }
    | d = def Semicolon l = listBindings { d :: l }

const:
    | True          { Ast.True       }
    | False         { Ast.False      }
    | n = Int       { Ast.Int n      }
    | c = Char      { Ast.Char c     }
    | s = String    { Ast.String s   }
