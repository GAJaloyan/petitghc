make

 echo "syntax/good"
 rsync -r --delete-after tests/ pretty/
 
 ./petitghc --parse-only pretty/syntax/good/testfile-comment-1.hs > pretty/syntax/good/testfile-comment-1.gv
 dot -Tps pretty/syntax/good/testfile-comment-1.gv -o pretty/syntax/good/testfile-comment-1.ps
 
 ./petitghc --parse-only pretty/syntax/good/testfile-semicolon-1.hs > pretty/syntax/good/testfile-semicolon-1.gv
 dot -Tps pretty/syntax/good/testfile-semicolon-1.gv -o pretty/syntax/good/testfile-semicolon-1.ps
 
 ./petitghc --parse-only pretty/syntax/good/testfile-semicolon-2.hs > pretty/syntax/good/testfile-semicolon-2.gv
 dot -Tps pretty/syntax/good/testfile-semicolon-2.gv -o pretty/syntax/good/testfile-semicolon-2.ps
 
 ./petitghc --parse-only pretty/syntax/good/testfile-semicolon-3.hs > pretty/syntax/good/testfile-semicolon-3.gv
 dot -Tps pretty/syntax/good/testfile-semicolon-3.gv -o pretty/syntax/good/testfile-semicolon-3.ps
 
 echo "syntax/good generated OK\n\n"
 
 
 echo "syntax/bad"
 ./petitghc --parse-only pretty/syntax/bad/testfile-character_literal-1.hs 
 ./petitghc --parse-only pretty/syntax/bad/testfile-lambda-1.hs 
 ./petitghc --parse-only pretty/syntax/bad/testfile-string_literal-1.hs 
 ./petitghc --parse-only pretty/syntax/bad/testfile-string_literal-3.hs 
 ./petitghc --parse-only pretty/syntax/bad/testfile-do-1.hs             
 ./petitghc --parse-only pretty/syntax/bad/testfile-lexical-1.hs  
 ./petitghc --parse-only pretty/syntax/bad/testfile-string_literal-2.hs 
 
 echo "syntax/bad done \n\n"
 

 echo "typing/good"
 ./petitghc --parse-only pretty/typing/good/testfile-arith-1.hs > pretty/typing/good/testfile-arith-1.gv
 dot -Tps pretty/typing/good/testfile-arith-1.gv -o pretty/typing/good/testfile-arith-1.ps
 
 ./petitghc --parse-only pretty/typing/good/testfile-arith-2.hs > pretty/typing/good/testfile-arith-2.gv
 dot -Tps pretty/typing/good/testfile-arith-2.gv -o pretty/typing/good/testfile-arith-2.ps
 
 ./petitghc --parse-only pretty/typing/good/testfile-error-1.hs > pretty/typing/good/testfile-error-1.gv
 dot -Tps pretty/typing/good/testfile-error-1.gv -o pretty/typing/good/testfile-error-1.ps
 
 ./petitghc --parse-only pretty/typing/good/testfile-error-2.hs > pretty/typing/good/testfile-error-2.gv
  dot -Tps pretty/typing/good/testfile-error-2.gv -o pretty/typing/good/testfile-error-2.ps
 
 ./petitghc --parse-only pretty/typing/good/testfile-error-3.hs > pretty/typing/good/testfile-error-3.gv
  dot -Tps pretty/typing/good/testfile-error-3.gv -o pretty/typing/good/testfile-error-3.ps
 
 ./petitghc --parse-only pretty/typing/good/testfile-hindley_milner-1.hs > pretty/typing/good/testfile-hindley_milner-1.gv
  dot -Tps pretty/typing/good/testfile-hindley_milner-1.gv -o pretty/typing/good/testfile-hindley_milner-1.ps
 
 ./petitghc --parse-only pretty/typing/good/testfile-shadowing-1.hs > pretty/typing/good/testfile-shadowing-1.gv
  dot -Tps pretty/typing/good/testfile-shadowing-1.gv -o pretty/typing/good/testfile-shadowing-1.ps
 
 echo "typing/bad"
 ./petitghc --parse-only pretty/typing/bad/testfile-arith-1.hs > pretty/typing/bad/testfile-arith-1.gv
 dot -Tps pretty/typing/bad/testfile-arith-1.gv -o pretty/typing/bad/testfile-arith-1.ps
 
 ./petitghc --parse-only pretty/typing/bad/testfile-error-1.hs > pretty/typing/bad/testfile-error-1.gv
 dot -Tps pretty/typing/bad/testfile-error-1.gv -o pretty/typing/bad/testfile-error-1.ps
 
 ./petitghc --parse-only pretty/typing/bad/testfile-main-1.hs > pretty/typing/bad/testfile-main-1.gv
 dot -Tps pretty/typing/bad/testfile-main-1.gv -o pretty/typing/bad/testfile-main-1.ps
 
 ./petitghc --parse-only pretty/typing/bad/testfile-main-2.hs > pretty/typing/bad/testfile-main-2.gv
 dot -Tps pretty/typing/bad/testfile-main-2.gv -o pretty/typing/bad/testfile-main-2.ps
 
 ./petitghc --parse-only pretty/typing/bad/testfile-duplicate-1.hs > pretty/typing/bad/testfile-duplicate-1.gv
 dot -Tps pretty/typing/bad/testfile-duplicate-1.gv -o pretty/typing/bad/testfile-duplicate-1.ps
 
 ./petitghc --parse-only pretty/typing/bad/testfile-duplicate-2.hs > pretty/typing/bad/testfile-duplicate-2.gv
 dot -Tps pretty/typing/bad/testfile-duplicate-2.gv -o pretty/typing/bad/testfile-duplicate-2.ps
 
 ./petitghc --parse-only pretty/typing/bad/testfile-duplicate-3.hs > pretty/typing/bad/testfile-duplicate-3.gv
 dot -Tps pretty/typing/bad/testfile-duplicate-3.gv -o pretty/typing/bad/testfile-duplicate-3.ps
 
 ./petitghc --parse-only pretty/typing/bad/testfile-duplicate-4.hs > pretty/typing/bad/testfile-duplicate-4.gv
 dot -Tps pretty/typing/bad/testfile-duplicate-4.gv -o pretty/typing/bad/testfile-duplicate-4.ps
 
 ./petitghc --parse-only pretty/typing/bad/testfile-duplicate-5.hs > pretty/typing/bad/testfile-duplicate-5.gv
 dot -Tps pretty/typing/bad/testfile-duplicate-5.gv -o pretty/typing/bad/testfile-duplicate-5.ps
 
 echo "typing/ generated OK\n\n"



 echo "exec"

#pretty/exec/append1.hs

 ./petitghc --parse-only pretty/exec/append1.hs > pretty/exec/append1.gv
 dot -Tps pretty/exec/append1.gv -o pretty/exec/append1.ps

#pretty/exec/church.hs

 ./petitghc --parse-only pretty/exec/church.hs > pretty/exec/church.gv
 dot -Tps pretty/exec/church.gv -o pretty/exec/church.ps

#pretty/exec/church2.hs

 ./petitghc --parse-only pretty/exec/church2.hs > pretty/exec/church2.gv
 dot -Tps pretty/exec/church2.gv -o pretty/exec/church2.ps
 
#pretty/exec/church3.hs

 ./petitghc --parse-only pretty/exec/church3.hs > pretty/exec/church3.gv
 dot -Tps pretty/exec/church3.gv -o pretty/exec/church3.ps
 
#pretty/exec/cycle1.hs

 ./petitghc --parse-only pretty/exec/cycle1.hs > pretty/exec/cycle1.gv
 dot -Tps pretty/exec/cycle1.gv -o pretty/exec/cycle1.ps

#pretty/exec/cycle2.hs

 ./petitghc --parse-only pretty/exec/cycle2.hs > pretty/exec/cycle2.gv
 dot -Tps pretty/exec/cycle2.gv -o pretty/exec/cycle2.ps

#pretty/exec/cycle3.hs

 ./petitghc --parse-only pretty/exec/cycle3.hs > pretty/exec/cycle3.gv
 dot -Tps pretty/exec/cycle3.gv -o pretty/exec/cycle3.ps
 
#pretty/exec/cycle4.hs

 ./petitghc --parse-only pretty/exec/cycle4.hs > pretty/exec/cycle4.gv
 dot -Tps pretty/exec/cycle4.gv -o pretty/exec/cycle4.ps
 
#pretty/exec/cycle5.hs

 ./petitghc --parse-only pretty/exec/cycle5.hs > pretty/exec/cycle5.gv
 dot -Tps pretty/exec/cycle5.gv -o pretty/exec/cycle5.ps

#pretty/exec/fib1.hs

 ./petitghc --parse-only pretty/exec/fib1.hs > pretty/exec/fib1.gv
 dot -Tps pretty/exec/fib1.gv -o pretty/exec/fib1.ps

#pretty/exec/iter1.hs
 
 ./petitghc --parse-only pretty/exec/iter1.hs > pretty/exec/iter1.gv
 dot -Tps pretty/exec/iter1.gv -o pretty/exec/iter1.ps

#pretty/exec/iter2.hs

 ./petitghc --parse-only pretty/exec/iter2.hs > pretty/exec/iter2.gv
 dot -Tps pretty/exec/iter2.gv -o pretty/exec/iter2.ps

#pretty/exec/iter3.hs

 ./petitghc --parse-only pretty/exec/iter3.hs > pretty/exec/iter3.gv
 dot -Tps pretty/exec/iter3.gv -o pretty/exec/iter3.ps

#pretty/exec/match0.hs

 ./petitghc --parse-only pretty/exec/match0.hs > pretty/exec/match0.gv
 dot -Tps pretty/exec/match0.gv -o pretty/exec/match0.ps

#pretty/exec/print_bool.hs

 ./petitghc --parse-only pretty/exec/print_bool.hs > pretty/exec/print_bool.gv
 dot -Tps pretty/exec/print_bool.gv -o pretty/exec/print_bool.ps

#pretty/exec/put_char1.hs

 ./petitghc --parse-only pretty/exec/put_char1.hs > pretty/exec/put_char1.gv
 dot -Tps pretty/exec/put_char1.gv -o pretty/exec/put_char1.ps

#pretty/exec/shadowing2.hs

 ./petitghc --parse-only pretty/exec/shadowing2.hs > pretty/exec/shadowing2.gv
 dot -Tps pretty/exec/shadowing2.gv -o pretty/exec/shadowing2.ps

#pretty/exec/array.hs

 ./petitghc --parse-only pretty/exec/array.hs > pretty/exec/array.gv
 dot -Tps pretty/exec/array.gv -o pretty/exec/array.ps

#pretty/exec/print_list1.hs

 ./petitghc --parse-only pretty/exec/print_list1.hs > pretty/exec/print_list1.gv
 dot -Tps pretty/exec/print_list1.gv -o pretty/exec/print_list1.ps
 
#pretty/exec/print_string.hs

 ./petitghc --parse-only pretty/exec/print_string.hs > pretty/exec/print_string.gv
 dot -Tps pretty/exec/print_string.gv -o pretty/exec/print_string.ps

#pretty/exec/print_string2.hs

 ./petitghc --parse-only pretty/exec/print_string2.hs > pretty/exec/print_string2.gv
 dot -Tps pretty/exec/print_string2.gv -o pretty/exec/print_string2.ps

#pretty/exec/fold_left1.hs

 ./petitghc --parse-only pretty/exec/fold_left1.hs > pretty/exec/fold_left1.gv
 dot -Tps pretty/exec/fold_left1.gv -o pretty/exec/fold_left1.ps

#pretty/exec/match1.hs

 ./petitghc --parse-only pretty/exec/match1.hs > pretty/exec/match1.gv
 dot -Tps pretty/exec/match1.gv -o pretty/exec/match1.ps
 
#pretty/exec/nth1.hs

 ./petitghc --parse-only pretty/exec/nth1.hs > pretty/exec/nth1.gv
 dot -Tps pretty/exec/nth1.gv -o pretty/exec/nth1.ps
 
#pretty/exec/print_int1.hs

 ./petitghc --parse-only pretty/exec/print_int1.hs > pretty/exec/print_int1.gv
 dot -Tps pretty/exec/print_int1.gv -o pretty/exec/print_int1.ps

#pretty/exec/queue1.hs

 ./petitghc --parse-only pretty/exec/queue1.hs > pretty/exec/queue1.gv
 dot -Tps pretty/exec/queue1.gv -o pretty/exec/queue1.ps

#pretty/exec/queue2.hs

 ./petitghc --parse-only pretty/exec/queue2.hs > pretty/exec/queue2.gv
 dot -Tps pretty/exec/queue2.gv -o pretty/exec/queue2.ps

#pretty/exec/bool1.hs

 ./petitghc --parse-only pretty/exec/bool1.hs > pretty/exec/bool1.gv
 dot -Tps pretty/exec/bool1.gv -o pretty/exec/bool1.ps

#pretty/exec/fun1.hs

 ./petitghc --parse-only pretty/exec/fun1.hs > pretty/exec/fun1.gv
 dot -Tps pretty/exec/fun1.gv -o pretty/exec/fun1.ps

#pretty/exec/lazy1.hs

 ./petitghc --parse-only pretty/exec/lazy1.hs > pretty/exec/lazy1.gv
 dot -Tps pretty/exec/lazy1.gv -o pretty/exec/lazy1.ps

#pretty/exec/lazy2.hs

 ./petitghc --parse-only pretty/exec/lazy2.hs > pretty/exec/lazy2.gv
 dot -Tps pretty/exec/lazy2.gv -o pretty/exec/lazy2.ps

#pretty/exec/lazy3.hs

 ./petitghc --parse-only pretty/exec/lazy3.hs > pretty/exec/lazy3.gv
 dot -Tps pretty/exec/lazy3.gv -o pretty/exec/lazy3.ps

#pretty/exec/lazy4.hs

 ./petitghc --parse-only pretty/exec/lazy4.hs > pretty/exec/lazy4.gv
 dot -Tps pretty/exec/lazy4.gv -o pretty/exec/lazy4.ps

#pretty/exec/lazy5.hs

 ./petitghc --parse-only pretty/exec/lazy5.hs > pretty/exec/lazy5.gv
 dot -Tps pretty/exec/lazy5.gv -o pretty/exec/lazy5.ps

#pretty/exec/lazy6.hs

 ./petitghc --parse-only pretty/exec/lazy6.hs > pretty/exec/lazy6.gv
 dot -Tps pretty/exec/lazy6.gv -o pretty/exec/lazy6.ps

#pretty/exec/mergesort1.hs

 ./petitghc --parse-only pretty/exec/mergesort1.hs > pretty/exec/mergesort1.gv
 dot -Tps pretty/exec/mergesort1.gv -o pretty/exec/mergesort1.ps

#pretty/exec/pascal.hs

 ./petitghc --parse-only pretty/exec/pascal.hs > pretty/exec/pascal.gv
 dot -Tps pretty/exec/pascal.gv -o pretty/exec/pascal.ps

#pretty/exec/call1.hs

 ./petitghc --parse-only pretty/exec/call1.hs > pretty/exec/call1.gv
 dot -Tps pretty/exec/call1.gv -o pretty/exec/call1.ps

#pretty/exec/call2.hs

 ./petitghc --parse-only pretty/exec/call2.hs > pretty/exec/call2.gv
 dot -Tps pretty/exec/call2.gv -o pretty/exec/call2.ps

#pretty/exec/compose1.hs

 ./petitghc --parse-only pretty/exec/compose1.hs > pretty/exec/compose1.gv
 dot -Tps pretty/exec/compose1.gv -o pretty/exec/compose1.ps

#pretty/exec/hello_world.hs

 ./petitghc --parse-only pretty/exec/hello_world.hs > pretty/exec/hello_world.gv
 dot -Tps pretty/exec/hello_world.gv -o pretty/exec/hello_world.ps

#pretty/exec/length1.hs

 ./petitghc --parse-only pretty/exec/length1.hs > pretty/exec/length1.gv
 dot -Tps pretty/exec/length1.gv -o pretty/exec/length1.ps

#pretty/exec/mutual1.hs

 ./petitghc --parse-only pretty/exec/mutual1.hs > pretty/exec/mutual1.gv
 dot -Tps pretty/exec/mutual1.gv -o pretty/exec/mutual1.ps

#pretty/exec/mutual2.hs

 ./petitghc --parse-only pretty/exec/mutual2.hs > pretty/exec/mutual2.gv
 dot -Tps pretty/exec/mutual2.gv -o pretty/exec/mutual2.ps

#pretty/exec/mutual3.hs

 ./petitghc --parse-only pretty/exec/mutual3.hs > pretty/exec/mutual3.gv
 dot -Tps pretty/exec/mutual3.gv -o pretty/exec/mutual3.ps

#pretty/exec/poly1.hs

 ./petitghc --parse-only pretty/exec/poly1.hs > pretty/exec/poly1.gv
 dot -Tps pretty/exec/poly1.gv -o pretty/exec/poly1.ps

#pretty/exec/quicksort1.hs

 ./petitghc --parse-only pretty/exec/quicksort1.hs > pretty/exec/quicksort1.gv
 dot -Tps pretty/exec/quicksort1.gv -o pretty/exec/quicksort1.ps

#pretty/exec/fact1.hs

 ./petitghc --parse-only pretty/exec/fact1.hs > pretty/exec/fact1.gv
 dot -Tps pretty/exec/fact1.gv -o pretty/exec/fact1.ps

#pretty/exec/mandelbrot.hs

 ./petitghc --parse-only pretty/exec/mandelbrot.hs > pretty/exec/mandelbrot.gv
 dot -Tps pretty/exec/mandelbrot.gv -o pretty/exec/mandelbrot.ps

#pretty/exec/primes.hs

 ./petitghc --parse-only pretty/exec/primes.hs > pretty/exec/primes.gv
 dot -Tps pretty/exec/primes.gv -o pretty/exec/primes.ps

#pretty/exec/shadowing1.hs

 ./petitghc --parse-only pretty/exec/shadowing1.hs > pretty/exec/shadowing1.gv
 dot -Tps pretty/exec/shadowing1.gv -o pretty/exec/shadowing1.ps

 echo "exec-fail"
 
#pretty/exec-fail/bool1.hs

 ./petitghc --parse-only pretty/exec-fail/bool1.hs > pretty/exec-fail/bool1.gv
 dot -Tps pretty/exec-fail/bool1.gv -o pretty/exec-fail/bool1.ps
 
#pretty/exec-fail/division_by_zero.hs

 ./petitghc --parse-only pretty/exec-fail/division_by_zero.hs > pretty/exec-fail/division_by_zero.gv
 dot -Tps pretty/exec-fail/division_by_zero.gv -o pretty/exec-fail/division_by_zero.ps
 
#pretty/exec-fail/error1.hs

 ./petitghc --parse-only pretty/exec-fail/error1.hs > pretty/exec-fail/error1.gv
 dot -Tps pretty/exec-fail/error1.gv -o pretty/exec-fail/error1.ps
 
#pretty/exec-fail/error2.hs

 ./petitghc --parse-only pretty/exec-fail/error2.hs > pretty/exec-fail/error2.gv
 dot -Tps pretty/exec-fail/error2.gv -o pretty/exec-fail/error2.ps
 
#pretty/exec-fail/error3.hs

 ./petitghc --parse-only pretty/exec-fail/error3.hs > pretty/exec-fail/error3.gv
 dot -Tps pretty/exec-fail/error3.gv -o pretty/exec-fail/error3.ps
 
#pretty/exec-fail/lazy1.hs

 ./petitghc --parse-only pretty/exec-fail/lazy1.hs > pretty/exec-fail/lazy1.gv
 dot -Tps pretty/exec-fail/lazy1.gv -o pretty/exec-fail/lazy1.ps
 
#pretty/exec-fail/shadowing1.hs

 ./petitghc --parse-only pretty/exec-fail/shadowing1.hs > pretty/exec-fail/shadowing1.gv
 dot -Tps pretty/exec-fail/shadowing1.gv -o pretty/exec-fail/shadowing1.ps
 

 echo "exec generated OK\n\n"
