let test_file tfile = 
     Printf.printf "%s\n" tfile;
     flush stdout;
     let _ = Main.parseFile tfile in ()

let goodFiles =
    [ "tests/syntax/good/testfile-comment-1.hs";
      "tests/syntax/good/testfile-semicolon-1.hs";
      "tests/syntax/good/testfile-semicolon-2.hs";
      "tests/syntax/good/testfile-semicolon-3.hs";
      "tests/syntax/good/testfile-string-1.hs";
      "tests/syntax/good/testfile-character_literal-1.hs";
      "tests/syntax/good/testfile-do-1.hs";
      "tests/syntax/good/testfile-lambda-1.hs";
      "tests/syntax/good/testfile-lexical-1.hs";
      "tests/syntax/good/testfile-string_literal-1.hs";
      "tests/syntax/good/testfile-string_literal-2.hs";
      "tests/syntax/good/testfile-string_literal-3.hs"
    ]

let badFiles =
    [ (*"tests/syntax/bad/testfile-character_literal-1.hs";
      "tests/syntax/bad/testfile-do-1.hs";
      "tests/syntax/bad/testfile-lambda-1.hs";
      "tests/syntax/bad/testfile-lexical-1.hs";
      "tests/syntax/bad/testfile-string_literal-1.hs";
      "tests/syntax/bad/testfile-string_literal-2.hs";
      "tests/syntax/bad/testfile-string_literal-3.hs"*)
    ]

let main () =
    Printf.printf "No error should happen\n";
    Printf.printf "%s\n"( Sys.getcwd ());
    flush stdout;
    List.iter test_file goodFiles;
    Printf.printf "Errors should be signaled\n";
    flush stdout;
    List.iter test_file badFiles

let () = main()
