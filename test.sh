make

echo "syntax/good"
./petitghc --parse-only tests/syntax/good/testfile-comment-1.hs  
./petitghc --parse-only tests/syntax/good/testfile-semicolon-1.hs  
./petitghc --parse-only tests/syntax/good/testfile-semicolon-2.hs  
./petitghc --parse-only tests/syntax/good/testfile-semicolon-3.hs

echo "syntax/bad"
./petitghc --parse-only tests/syntax/bad/testfile-character_literal-1.hs  
./petitghc --parse-only tests/syntax/bad/testfile-lambda-1.hs   
./petitghc --parse-only tests/syntax/bad/testfile-string_literal-1.hs  
./petitghc --parse-only tests/syntax/bad/testfile-string_literal-3.hs
./petitghc --parse-only tests/syntax/bad/testfile-do-1.hs                 
./petitghc --parse-only tests/syntax/bad/testfile-lexical-1.hs  
./petitghc --parse-only tests/syntax/bad/testfile-string_literal-2.hs

echo "exec"
./petitghc tests/exec/append1.hs   
./petitghc tests/exec/church2.hs    
./petitghc tests/exec/cycle2.hs   
./petitghc tests/exec/fib1.hs          
./petitghc tests/exec/iter2.hs   
./petitghc tests/exec/lazy4.hs        
./petitghc tests/exec/match0.hs       
./petitghc tests/exec/mutual3.hs   
./petitghc tests/exec/print_bool.hs      
./petitghc tests/exec/put_char1.hs    
./petitghc tests/exec/shadowing2.hs
./petitghc tests/exec/array.hs     
./petitghc tests/exec/church3.hs    
./petitghc tests/exec/cycle3.hs   
./petitghc tests/exec/fold_left1.hs    
./petitghc tests/exec/iter3.hs   
./petitghc tests/exec/lazy5.hs        
./petitghc tests/exec/match1.hs       
./petitghc tests/exec/nth1.hs      
./petitghc tests/exec/print_int1.hs      
./petitghc tests/exec/queue1.hs
./petitghc tests/exec/bool1.hs     
./petitghc tests/exec/church.hs     
./petitghc tests/exec/cycle4.hs   
./petitghc tests/exec/fun1.hs          
./petitghc tests/exec/lazy1.hs   
./petitghc tests/exec/lazy6.hs        
./petitghc tests/exec/mergesort1.hs   
./petitghc tests/exec/pascal.hs    
./petitghc tests/exec/print_list1.hs     
./petitghc tests/exec/queue2.hs
./petitghc tests/exec/call1.hs     
./petitghc tests/exec/compose1.hs   
./petitghc tests/exec/cycle5.hs   
./petitghc tests/exec/hello_world.hs   
./petitghc tests/exec/lazy2.hs   
./petitghc tests/exec/length1.hs      
./petitghc tests/exec/mutual1.hs      
./petitghc tests/exec/poly1.hs     
./petitghc tests/exec/print_string2.hs   
./petitghc tests/exec/quicksort1.hs
./petitghc tests/exec/call2.hs     
./petitghc tests/exec/cycle1.hs     
./petitghc tests/exec/fact1.hs    
./petitghc tests/exec/iter1.hs         
./petitghc tests/exec/lazy3.hs   
./petitghc tests/exec/mandelbrot.hs   
./petitghc tests/exec/mutual2.hs      
./petitghc tests/exec/primes.hs    
./petitghc tests/exec/print_string.hs    
./petitghc tests/exec/shadowing1.hs

echo "exec-fail"

./petitghc tests/exec-fail/bool1.hs  
./petitghc tests/exec-fail/division_by_zero.hs  
./petitghc tests/exec-fail/error1.hs  
./petitghc tests/exec-fail/error2.hs  
./petitghc tests/exec-fail/error3.hs  
./petitghc tests/exec-fail/lazy1.hs  
./petitghc tests/exec-fail/shadowing1.hs
