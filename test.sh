# make

# echo "syntax/good"
# ./petitghc --parse-only tests/syntax/good/testfile-comment-1.hs  
# ./petitghc --parse-only tests/syntax/good/testfile-semicolon-1.hs  
# ./petitghc --parse-only tests/syntax/good/testfile-semicolon-2.hs  
# ./petitghc --parse-only tests/syntax/good/testfile-semicolon-3.hs
# 
# echo "syntax/bad"
# ./petitghc --parse-only tests/syntax/bad/testfile-character_literal-1.hs  
# ./petitghc --parse-only tests/syntax/bad/testfile-lambda-1.hs   
# ./petitghc --parse-only tests/syntax/bad/testfile-string_literal-1.hs  
# ./petitghc --parse-only tests/syntax/bad/testfile-string_literal-3.hs
# ./petitghc --parse-only tests/syntax/bad/testfile-do-1.hs                 
# ./petitghc --parse-only tests/syntax/bad/testfile-lexical-1.hs  
# ./petitghc --parse-only tests/syntax/bad/testfile-string_literal-2.hs

# echo "typing/good"
# ./petitghc --type-only tests/typing/good/testfile-arith-1.hs
# ./petitghc --type-only tests/typing/good/testfile-arith-2.hs
# ./petitghc --type-only tests/typing/good/testfile-error-1.hs
# ./petitghc --type-only tests/typing/good/testfile-error-2.hs
# ./petitghc --type-only tests/typing/good/testfile-error-3.hs
# ./petitghc --type-only tests/typing/good/testfile-hindley_milner-1.hs
# ./petitghc --type-only tests/typing/good/testfile-shadowing-1.hs
# 
# echo "typing/bad"
# ./petitghc --type-only tests/typing/bad/testfile-arith-1.hs
# ./petitghc --type-only tests/typing/bad/testfile-duplicate-2.hs
# ./petitghc --type-only tests/typing/bad/testfile-duplicate-4.hs
# ./petitghc --type-only tests/typing/bad/testfile-error-1.hs
# ./petitghc --type-only tests/typing/bad/testfile-main-2.hs
# ./petitghc --type-only tests/typing/bad/testfile-duplicate-1.hs
# ./petitghc --type-only tests/typing/bad/testfile-duplicate-3.hs
# ./petitghc --type-only tests/typing/bad/testfile-duplicate-5.hs
# ./petitghc --type-only tests/typing/bad/testfile-main-1.hs

# echo "exec"
echo "tests/exec/append1.hs"  
./petitghc -o outfile.s tests/exec/append1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/append1.out tmp
rm tmp
echo "tests/exec/church.hs" 
./petitghc -o outfile.s tests/exec/church.hs     
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/church.out tmp
rm tmp
echo "tests/exec/church2.hs" 
./petitghc -o outfile.s tests/exec/church2.hs    
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/church2.out tmp
rm tmp
echo "tests/exec/cycle2.hs"   
./petitghc -o outfile.s tests/exec/cycle2.hs   
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/cycle2.out tmp
rm tmp
echo "tests/exec/fib1.hs"
./petitghc -o outfile.s  tests/exec/fib1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/fib1.out tmp
rm tmp
echo "tests/exec/iter2.hs" 
./petitghc -o outfile.s  tests/exec/iter2.hs   
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/iter2.out tmp
rm tmp
echo "tests/exec/lazy4.hs"
./petitghc -o outfile.s  tests/exec/lazy4.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/lazy4.out tmp
rm tmp
echo "tests/exec/match0.hs"
./petitghc -o outfile.s  tests/exec/match0.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/match0.out tmp
rm tmp
echo "tests/exec/mutual3.hs"
./petitghc -o outfile.s  tests/exec/mutual3.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/mutual3.out tmp
rm tmp
echo "tests/exec/print_bool.hs"
./petitghc -o outfile.s  tests/exec/print_bool.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/print_bool.out tmp
rm tmp
echo "tests/exec/put_char1.hs"
./petitghc -o outfile.s  tests/exec/put_char1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/put_char1.out tmp
rm tmp
echo "tests/exec/shadowing2.hs"
./petitghc -o outfile.s  tests/exec/shadowing2.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/shadowing2.out tmp
rm tmp
echo "tests/exec/array.hs"
./petitghc -o outfile.s  tests/exec/array.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/array.out tmp
rm tmp
echo "tests/exec/church3.hs"
./petitghc -o outfile.s  tests/exec/church3.hs
spim -ldata 4000000 -file outfile.s | tail -n+6 > tmp
diff tests/exec/church3.out tmp
rm tmp
echo "tests/exec/cycle3.hs"
./petitghc -o outfile.s  tests/exec/cycle3.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/cycle3.out tmp
rm tmp
echo "tests/exec/fold_left1.hs"
./petitghc -o outfile.s  tests/exec/fold_left1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/fold_left1.out tmp
rm tmp
echo "tests/exec/iter3.hs"
./petitghc -o outfile.s  tests/exec/iter3.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/iter3.out tmp
rm tmp
echo "tests/exec/lazy5.hs"
./petitghc -o outfile.s  tests/exec/lazy5.hs
spim -lstack 1000000 -file outfile.s | tail -n+6 > tmp
diff tests/exec/lazy5.out tmp
rm tmp
echo "tests/exec/match1.hs"
./petitghc -o outfile.s  tests/exec/match1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/match1.out tmp
rm tmp
echo "tests/exec/nth1.hs"
./petitghc -o outfile.s  tests/exec/nth1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/nth1.out tmp
rm tmp
echo "tests/exec/print_int1.hs"
./petitghc -o outfile.s  tests/exec/print_int1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/print_int1.out tmp
rm tmp
echo "tests/exec/queue1.hs"
./petitghc -o outfile.s  tests/exec/queue1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/queue1.out tmp
rm tmp
echo "tests/exec/bool1.hs"
./petitghc -o outfile.s  tests/exec/bool1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/bool1.out tmp
rm tmp
echo "tests/exec/cycle4.hs"
./petitghc -o outfile.s  tests/exec/cycle4.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/cycle4.out tmp
rm tmp
echo "tests/exec/fun1.hs"
./petitghc -o outfile.s  tests/exec/fun1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/fun1.out tmp
rm tmp
echo "tests/exec/lazy1.hs"
./petitghc -o outfile.s  tests/exec/lazy1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/lazy1.out tmp
rm tmp
echo "tests/exec/lazy6.hs"
./petitghc -o outfile.s  tests/exec/lazy6.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/lazy6.out tmp
rm tmp
echo "tests/exec/mergesort1.hs"
./petitghc -o outfile.s  tests/exec/mergesort1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/mergesort1.out tmp
rm tmp
echo "tests/exec/pascal.hs"
./petitghc -o outfile.s  tests/exec/pascal.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/pascal.out tmp
rm tmp
echo "tests/exec/print_list1.hs"
./petitghc -o outfile.s  tests/exec/print_list1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/print_list1.out tmp
rm tmp
echo "tests/exec/queue2.hs"
./petitghc -o outfile.s  tests/exec/queue2.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/queue2.out tmp
rm tmp
echo "tests/exec/call1.hs"
./petitghc -o outfile.s tests/exec/call1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/call1.out tmp
rm tmp
echo "tests/exec/compose1.hs"
./petitghc -o outfile.s tests/exec/compose1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/compose1.out tmp
rm tmp
echo "tests/exec/cycle5.hs"
./petitghc -o outfile.s tests/exec/cycle5.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/cycle5.out tmp
rm tmp
echo "tests/exec/hello_world.hs"
./petitghc -o outfile.s tests/exec/hello_world.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/hello_world.out tmp
rm tmp
echo "tests/exec/lazy2.hs"
./petitghc -o outfile.s tests/exec/lazy2.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/lazy2.out tmp
rm tmp
echo "tests/exec/length1.hs"
./petitghc -o outfile.s tests/exec/length1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/length1.out tmp
rm tmp
echo "tests/exec/mutual1.hs"
./petitghc -o outfile.s tests/exec/mutual1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/mutual1.out tmp
rm tmp
echo "tests/exec/poly1.hs"
./petitghc -o outfile.s tests/exec/poly1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/poly1.out tmp
rm tmp
echo "tests/exec/print_string2.hs"
./petitghc -o outfile.s tests/exec/print_string2.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/print_string2.out tmp
rm tmp
echo "tests/exec/quicksort1.hs"
./petitghc -o outfile.s tests/exec/quicksort1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/quicksort1.out tmp
rm tmp
echo "tests/exec/call2.hs"
./petitghc -o outfile.s tests/exec/call2.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/call2.out tmp
rm tmp
echo "tests/exec/cycle1.hs"
./petitghc -o outfile.s tests/exec/cycle1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/cycle1.out tmp
rm tmp
echo "tests/exec/fact1.hs"
./petitghc -o outfile.s tests/exec/fact1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/fact1.out tmp
rm tmp
echo "tests/exec/iter1.hs"
./petitghc -o outfile.s tests/exec/iter1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/iter1.out tmp
rm tmp
echo "tests/exec/lazy3.hs"
./petitghc -o outfile.s tests/exec/lazy3.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/lazy3.out tmp
rm tmp
echo "tests/exec/mandelbrot.hs"
./petitghc -o outfile.s tests/exec/mandelbrot.hs
spim -ldata 8000000 -file outfile.s | tail -n+6 > tmp
diff tests/exec/mandelbrot.out tmp
rm tmp
echo "tests/exec/mutual2.hs"
./petitghc -o outfile.s tests/exec/mutual2.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/mutual2.out tmp
rm tmp
echo "tests/exec/primes.hs"
./petitghc -o outfile.s tests/exec/primes.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/primes.out tmp
rm tmp
echo "tests/exec/print_string.hs" 
./petitghc -o outfile.s tests/exec/print_string.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/print_string.out tmp
rm tmp
echo "tests/exec/shadowing1.hs"
./petitghc -o outfile.s tests/exec/shadowing1.hs
spim -file outfile.s | tail -n+6 > tmp
diff tests/exec/shadowing1.out tmp
rm tmp

# echo "exec-fail"
# 
# echo "tests/exec-fail/bool1.hs" 
# ./petitghc tests/exec-fail/bool1.hs  
# spim -file outfile.s
# echo "tests/exec-fail/division_by_zero.hs" 
# ./petitghc tests/exec-fail/division_by_zero.hs  
# spim -file outfile.s
# echo "tests/exec-fail/error1.hs"
# ./petitghc tests/exec-fail/error1.hs  
# spim -file outfile.s
# echo "tests/exec-fail/error2.hs" 
# ./petitghc tests/exec-fail/error2.hs  
# spim -file outfile.s
# echo "tests/exec-fail/error3.hs"
# ./petitghc tests/exec-fail/error3.hs  
# spim -file outfile.s
# echo "tests/exec-fail/lazy1.hs"
# ./petitghc tests/exec-fail/lazy1.hs  
# spim -file outfile.s
# echo "tests/exec-fail/shadowing1.hs"
# ./petitghc tests/exec-fail/shadowing1.hs
# spim -file outfile.s
