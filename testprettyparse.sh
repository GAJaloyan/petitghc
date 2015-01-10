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



# echo "exec"
#tests/exec/append1.hs
#tests/exec/church.hs
#tests/exec/church2.hs
#tests/exec/cycle2.hs
#tests/exec/fib1.hs
#tests/exec/iter2.hs
#tests/exec/lazy4.hs
#tests/exec/match0.hs
#tests/exec/mutual3.hs
#tests/exec/print_bool.hs
#tests/exec/put_char1.hs
#tests/exec/shadowing2.hs
#tests/exec/array.hs
#tests/exec/church3.hs
#tests/exec/cycle3.hs
#tests/exec/fold_left1.hs
#tests/exec/iter3.hs
#tests/exec/lazy5.hs
#tests/exec/match1.hs
#tests/exec/nth1.hs
#tests/exec/print_int1.hs
#tests/exec/queue1.hs
#tests/exec/bool1.hs
#tests/exec/cycle4.hs
#tests/exec/fun1.hs
#tests/exec/lazy1.hs
#tests/exec/lazy6.hs
#tests/exec/mergesort1.hs
#tests/exec/pascal.hs
#tests/exec/print_list1.hs
#tests/exec/queue2.hs
#tests/exec/call1.hs
#tests/exec/compose1.hs
#tests/exec/cycle5.hs
#tests/exec/hello_world.hs
#tests/exec/lazy2.hs
#tests/exec/length1.hs
#tests/exec/mutual1.hs
#tests/exec/poly1.hs
#tests/exec/print_string2.hs
#tests/exec/quicksort1.hs
#tests/exec/call2.hs
#tests/exec/cycle1.hs
#tests/exec/fact1.hs
#tests/exec/iter1.hs
#tests/exec/lazy3.hs
#tests/exec/mandelbrot.hs
#tests/exec/mutual2.hs
#tests/exec/primes.hs
#tests/exec/print_string.hs
#tests/exec/shadowing1.hs

# echo "exec-fail"
#tests/exec-fail/bool1.hs
#tests/exec-fail/division_by_zero.hs
#tests/exec-fail/error1.hs
#tests/exec-fail/error2.hs
#tests/exec-fail/error3.hs
#tests/exec-fail/lazy1.hs
#tests/exec-fail/shadowing1.hs

