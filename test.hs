-- main = let x = False and y = x in if y then putChar 't' else putChar 'f'
f x = putChar x
main = f 'c' 
