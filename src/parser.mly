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
%token <char> Char
%token <string> String

%start <Ast.file> file
%%

file:
    | Eof { [] }
    | d = definition ds = file { d :: ds }

definition:
    | i = Ident is = identList Assign e = expression { (i,is,e) }

simple_expression:
    | LeftPar e = expression RightPar { Ast.Par e }
    | i = Ident                       { Ast.Id i }
    | c = const                       { Ast.Cst c }
    | RightBracket l = list           { Ast.List l }

list:
    | e = expression Comma l = list { e :: l }
    | e = expression LeftBracket    { [e] }
    | LeftBracket                   { [] }

expression:
    | e = simple_expression { Ast.Simple e }
    | Lambda s = param e = expression { Ast.Lambda (s,e) }
    | Minus e = expression { Ast.Ned expression }
    | e1 = expression o = op e2 = expression { Ast.BinOp (e1,o,e2) }
    | If e1 = expression Then e2 = expression Else e3 = expression { Ast.If (e1,e2,e3) }
    | Let b = bindings In e = expression { Ast.Let (b,e) }
    | Case e1 = expression Of LeftCurly LeftBracket RightBracket Arrow e2 = expression Semicolon i = Ident Colon is = Ident Arrow e3 = expression Semicolon? RightCurly { Ast.Case (e1,e2,i,is,e3) }
    | Do LeftBracket l = toDo { Do l }
    | Return LeftPar RightPar { Return }

toDo:
    | d = expression Semicolon? RightBracket { [] }
    | d = expression Semicolon l = toDo { d :: l }

identList:
    | i = Ident l = identList { (Ast.Id i) :: l }
    | Equal { [] }

param:
    | i = Ident p = param { (Ast.Id i) :: p }
    | i = Ident Arrow { [Ast.Id i] }

bindings:
    | d = definition { Ast.Def d }
    | LeftBracket l = listBindings { Ast.ListDef l }

listBindings:
    | Semicolon? LeftBracket { [] }
    | d = definition Semicolon l = listBindings { d :: l }

op:
    | Plus      { Ast.Plus       }
    | Minus     { Ast.Minus      }
    | Time      { Ast.Time       }
    | LowerEq   { Ast.LowerEq    }
    | GreaterEq { Ast.GreaterEq  }
    | Lower     { Ast.Lower      }
    | Greater   { Ast.Greater    }
    | Unequal   { Ast.Unequal    }
    | Equal     { Ast.Equal      }
    | And       { Ast.And        }
    | Or        { Ast.Or         }
    | Colon     { Ast.Colon      }

const:
    | True          { Ast.True       }
    | False         { Ast.False      }
    | n = Int       { Ast.Int n      }
    | c = Char      { Ast.Char c     }
    | s = String    { Ast.String s   }
