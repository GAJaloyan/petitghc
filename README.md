Compilation : Petit Haskell to MIPS


[![Build Status](https://travis-ci.org/GAJaloyan/petitghc.svg?branch=master)](https://travis-ci.org/GAJaloyan/petitghc)
    
This is our compilation project for the course on compilation at the ENS Paris. The goal
is to make a compiler for a portion of haskell, called Petit Haskell, producted in MIPS. It
contains only integers and lists and is 100% compatible with Haskell.

===========================================
About PetitHaskell:

Lexical conventions: spaces, tabulations and newlines are considered as blank characters.
Comments start with a -- and end at the end of the line. The identifiers obey the
regular expression <indent> with is:

<digit> ::= 0-9
<alpha> ::= a-z | A-Z
<ident> ::= (a-z) (<alpha> | _ | ' | <digit>)*

In what follows, <ident_0> is the identifier placed in the first column and <ident_1> is
any other identifier.

The following identifiers are key words:
else - if - in - let - case - of - then - return - do

Finally, the litterals obey the following regular expressions:

<int> ::= <digit>+
<car> ::= any ASCII character whose code is in between 32 and 126 inclusive 
          different then \ and "
<character> ::= '<car>'
<chain> ::= "<car>*"

The following grammar is the one of the source files. The input point is the non-terminal
<file>. The associativities and the precedences of the operators are given in this table,
from the weakest to the strongest:

|------------------------|---------------|
|Operator                | Associativity |
|------------------------|---------------|
| in                     |               |
| else                   |               |
| ->                     |               |
| ||                     | left          |
| &&                     | left          |
| < <= > >= == /=        | left          |
| :                      | right         |
| + -                    | left          |
| *                      | left          |
| - (unary)              |               |
| function application   | left          |
|------------------------|---------------|

<file> ::= <def_0>* EOF
<def_0> ::= <ident_0> <ident_1>* = <expr>
<def>   ::= <ident_1> <ident_1>* = <expr>
<simple_expr>   ::= ( <expr> ) | <ident_1> | <const> | [ <expr>_,*]
<expr> ::= 
       | <simple_expr>+
       | \ <ident_1>+ -> <expr>
       | - <expr> | <expr> <op> <expr>
       | if <expr> then <expr> else <expr>
       | let <bindings> in <expr>
       | case <expr> of { [ ] -> <expr>; <ident_1> : <ident_1> -> <expr> ;? }
       | do { <expr>_;+;? }
       | return ( )
<bindings> ::= <def> | { <def>_;+;? }
<op>       ::= + | - | * | <= | >= | > | < | /= | == | && | || | :
<const>    ::= True | False | <int> | <caracter> | <chain>


The file is compiled as follows: putChar, error, rem and div are
always included in the object code. They are associated with 4
variables, each one containing an empty closure to these functions.
Next, the stack contains has many variables as there are global
definitions.



===========================================
Usage : 
make
./petitghc [options] [-o outputfile.s] inputfile.hs

Options :
--parse-only : parses the inputfile, then prints a graphviz code of the 
               constructed ast on stdout, then exits.
--type-only : types the inputfile, then prints a graphviz code of the typed 
              ast on stdout, then exits.
--simplify-only : simplifies the ast, then prints a graphviz code of the 
                  simplified ast on stdout, then exits.
-o : the output file if specified, else set to inputfile.s

Needed :
ocaml version 4.02.1
dot - graphviz version 2.36.0
rsync version 3.1.0

============================================
About the code:

All the sources are inside src.

- mips.ml and mips.mli are the ones from the course webpage with the addition 
  of functions for j and pushn.

- error.ml was taken from the minijazz implementation from the course Système 
  digital with minor modifications: it allows us to print the line where an 
  error occured during compilation with an indication of the position of the 
  error.

- lexer.mll is used for the lexing.

- parser.mly is for the parsing: it outputs an ast whose implementation is in
  ast.ml, it can be printed using printer.ml.

- typage.ml is for the type inference of the ast from the parser: it can create
  a typed ast, its interface is in typage.mli and typprinter.ml allows the
  pretty printing of its result.

- adapt.ml transforms the ast from the parser into a new ast which is simpler
  to use for the code transformation.

- simplify.ml expands the \ x_1 ... x_n -> ... in \ x_1 -> ... \x_n -> ... and
  puts the thunks: \ _ -> G ( ...  ), its result is an ast whose type is inside
  inter.ml. Its result can be pretty printed using simpleprinter.ml.

- make_closure.ml implements the creation of the closures of the simplified ast
  and also takes care scope analysis.

- genCode.ml deals with generation of mips code from the closured ast, by using
  the module Mips.

============================================
Code generation:

The convention is that an expression returns its result inside v0. The closure
is inside a1 and the argument inside a2.

To reduce heap allocation, two constant: null and true are put inside the data
segment and returned inside the equality tests.

============================================
Difficulties:

Due to the difficulty debugging of the code generation phase, we decided to
merge our two project and to make it together. We reused mainly Georges-
Axel's code for the front end, while the back end convention comes from
Cyrille's code, this explains the difference of conventions in the
implementation and the presence of an adpat.ml file to make the transition
between the two representations.

The main difficulties was the unfamiliarity with the tools and some technic
details of the assignment.

Almost all programs on sas.eleves.ens.fr were outdated, and the code did not 
compile on older versions of ocaml. We had to recompile ocaml on a ~/bin 
folder to be able to test our code. The same problem appeared with graphviz 
dot. 

The lexer / parser was modified a bit to adapt the ast (tranformations like
def0 a b c = e --> def0 = \ a b c -> e), and storage of the localisation
in a more precise manner using error.ml.

The typing was mainly implemented using TD 4, we tried to make the error
report as precise as possible using error.ml to try to follow Ocaml's
compiler error reports.

For code generation, first the goal was to compile: main = return (). Since it
was transformed into: main = \ _ -> G (return ()), the thunk allocation and
the force function needed to be implemented, as well as closure creation. Some
bugs were found due to a misunderstanding of closure creation, but this was not
too hard.

Next, the goal was to compile main = putChar 'c', for this, putChar and function
application needed to be implemented and then in a rush, everythin else was
implemented (it was probably not the best method).

While testing it appeared that in function application, the argument should not
be forced before applying the function, the first implementations for && and ||
were also not lazy. But it was fixed.

After a few days, all the tests passed, except 3: it appeared that there were
a gap of 4 bytes inside the activation records of the functions, which
overwrited the saved fp. It did not appeared in the other tests, because most
of them were written in a functionnal style, so that there were no need to
fetch the fp as in as do { e1;e2 } where after e1 evaluation, fp needed to be
fetched for the creation of the activation record of the functions inside e2.

Now, everything compiles, except that for some test files, spim must be
provided a new max stack / heap.
