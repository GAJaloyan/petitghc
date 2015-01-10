print_list l =
  case l of {
    [] -> return ();
    x : xs -> return ()
    }

main = let s = [0] in
  do {
    print_list s;
    print_list s;
  }
