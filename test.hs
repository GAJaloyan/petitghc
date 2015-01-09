--zero f x = x
--one f x = f x
add1 n f x = f (n f x)
--
--two = add1 zero
--
-- print_string l = case l of {
--   [] -> putChar '\n';
--   x : y -> do {putChar x; print_string y}
-- }
-- 
-- to_string n = n (\x -> 'S' : x) ['0']
-- 
-- print_nat n = print_string (to_string n)
-- 
-- main = do {print_nat zero; print_nat one; print_nat two}
main = return ()
