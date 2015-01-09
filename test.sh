make

#echo "syntax/good"
#./petitghc --parse-only tests/syntax/good/testfile-comment-1.hs  
#./petitghc --parse-only tests/syntax/good/testfile-semicolon-1.hs  
#./petitghc --parse-only tests/syntax/good/testfile-semicolon-2.hs  
#./petitghc --parse-only tests/syntax/good/testfile-semicolon-3.hs

#echo "syntax/bad"
#./petitghc --parse-only tests/syntax/bad/testfile-character_literal-1.hs  
#./petitghc --parse-only tests/syntax/bad/testfile-lambda-1.hs   
#./petitghc --parse-only tests/syntax/bad/testfile-string_literal-1.hs  
#./petitghc --parse-only tests/syntax/bad/testfile-string_literal-3.hs
#./petitghc --parse-only tests/syntax/bad/testfile-do-1.hs                 
#./petitghc --parse-only tests/syntax/bad/testfile-lexical-1.hs  
#./petitghc --parse-only tests/syntax/bad/testfile-string_literal-2.hs

echo "exec"
./petitghc tests/exec/append1.hs   
spim -file outfile.s
./petitghc tests/exec/church2.hs    
java -jar Mars4_5.jar outfile.s
# ./petitghc tests/exec/cycle2.hs   
# spim -file outfile.s
# ./petitghc tests/exec/fib1.hs          
# spim -file outfile.s
# ./petitghc tests/exec/iter2.hs   
# spim -file outfile.s
# ./petitghc tests/exec/lazy4.hs        
# spim -file outfile.s
# ./petitghc tests/exec/match0.hs       
# spim -file outfile.s
# ./petitghc tests/exec/mutual3.hs   
# spim -file outfile.s
# ./petitghc tests/exec/print_bool.hs      
# spim -file outfile.s
# ./petitghc tests/exec/put_char1.hs    
# spim -file outfile.s
# ./petitghc tests/exec/shadowing2.hs
# spim -file outfile.s
# ./petitghc tests/exec/array.hs     
# spim -file outfile.s
# ./petitghc tests/exec/church3.hs    
# spim -file outfile.s
# ./petitghc tests/exec/cycle3.hs   
# spim -file outfile.s
# ./petitghc tests/exec/fold_left1.hs    
# spim -file outfile.s
# ./petitghc tests/exec/iter3.hs   
# spim -file outfile.s
# ./petitghc tests/exec/lazy5.hs        
# spim -file outfile.s
# ./petitghc tests/exec/match1.hs       
# spim -file outfile.s
# ./petitghc tests/exec/nth1.hs      
# spim -file outfile.s
# ./petitghc tests/exec/print_int1.hs      
# spim -file outfile.s
# ./petitghc tests/exec/queue1.hs
# spim -file outfile.s
# ./petitghc tests/exec/bool1.hs     
# spim -file outfile.s
# ./petitghc tests/exec/church.hs     
# spim -file outfile.s
# ./petitghc tests/exec/cycle4.hs   
# spim -file outfile.s
# ./petitghc tests/exec/fun1.hs          
# spim -file outfile.s
# ./petitghc tests/exec/lazy1.hs   
# spim -file outfile.s
# ./petitghc tests/exec/lazy6.hs        
# spim -file outfile.s
# ./petitghc tests/exec/mergesort1.hs   
# spim -file outfile.s
# ./petitghc tests/exec/pascal.hs    
# spim -file outfile.s
# ./petitghc tests/exec/print_list1.hs     
# spim -file outfile.s
# ./petitghc tests/exec/queue2.hs
# spim -file outfile.s
# ./petitghc tests/exec/call1.hs     
# spim -file outfile.s
# ./petitghc tests/exec/compose1.hs   
# spim -file outfile.s
# ./petitghc tests/exec/cycle5.hs   
# spim -file outfile.s
# ./petitghc tests/exec/hello_world.hs   
# spim -file outfile.s
# ./petitghc tests/exec/lazy2.hs   
# spim -file outfile.s
# ./petitghc tests/exec/length1.hs      
# spim -file outfile.s
# ./petitghc tests/exec/mutual1.hs      
# spim -file outfile.s
# ./petitghc tests/exec/poly1.hs     
# spim -file outfile.s
# ./petitghc tests/exec/print_string2.hs   
# spim -file outfile.s
# ./petitghc tests/exec/quicksort1.hs
# spim -file outfile.s
# ./petitghc tests/exec/call2.hs     
# spim -file outfile.s
# ./petitghc tests/exec/cycle1.hs     
# spim -file outfile.s
# ./petitghc tests/exec/fact1.hs    
# spim -file outfile.s
# ./petitghc tests/exec/iter1.hs         
# spim -file outfile.s
# ./petitghc tests/exec/lazy3.hs   
# spim -file outfile.s
# ./petitghc tests/exec/mandelbrot.hs   
# spim -file outfile.s
# ./petitghc tests/exec/mutual2.hs      
# spim -file outfile.s
# ./petitghc tests/exec/primes.hs    
# spim -file outfile.s
# ./petitghc tests/exec/print_string.hs    
# spim -file outfile.s
# ./petitghc tests/exec/shadowing1.hs
# spim -file outfile.s

echo "exec-fail"

#./petitghc tests/exec-fail/bool1.hs  
#./petitghc tests/exec-fail/division_by_zero.hs  
#./petitghc tests/exec-fail/error1.hs  
#./petitghc tests/exec-fail/error2.hs  
#./petitghc tests/exec-fail/error3.hs  
#./petitghc tests/exec-fail/lazy1.hs  
#./petitghc tests/exec-fail/shadowing1.hs
