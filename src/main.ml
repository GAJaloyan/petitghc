open Format

let parse_only = ref false
let type_only = ref false
let simplify_only = ref false

(* Noms des fichiers source et cible *)
let ifile = ref ""
let ofile = ref ""

let set_file f s = f := s

(* Les options du compilateur que l'on affiche avec --help *)
let options =
  ["--parse-only", Arg.Set parse_only,
   "  Pour ne faire uniquement que la phase d'analyse syntaxique"; "--type-only", Arg.Set type_only,
   "  Pour s'arrêter après le typage"; "--simplify-only", Arg.Set simplify_only,
   "  Pour s'arrêter après la simplification"; "-o", Arg.String (set_file ofile), 
   "-o <file>  Pour indiquer le mom du fichier de sortie"]

let usage = "usage: petitghc [option] file.hs"

let localisationAffiche (pos1, pos2) =
  let l = pos1.Lexing.pos_lnum in
  let c = pos1.Lexing.pos_cnum - pos1.Lexing.pos_bol + 1 in
  let l2 = pos2.Lexing.pos_lnum in
  let c2 = pos2.Lexing.pos_cnum - pos2.Lexing.pos_bol + 1 in
  eprintf "File \"%s\", line %d-%d, characters %d-%d:\n" !ifile l l2 (c) c2

let () = 
  Arg.parse options (set_file ifile) usage; 

  if !ifile="" then begin eprintf "Aucun fichier à compiler\n@?"; exit 1 end;
        
  if not (Filename.check_suffix !ifile ".hs") then begin
    eprintf "Le fichier d'entrée doit avoir l'extension .hs\n@?";
    Arg.usage options usage;
    exit 1
  end;  
        
  let f = open_in !ifile in
        
  if !ofile="" then ofile := Filename.chop_suffix !ifile ".hs" ^ ".s";
  
  (* Création d'un tampon d'analyse lexicale *)
  let buf = Lexing.from_channel f in
  try
    let p = Parser.fichier Lexer.token buf in begin
    close_in f;
    
    (* On s'arrête ici si on ne veut faire que le parsing *)
    if !parse_only then begin  Printer.print_fichier p; exit 0; end;

    let tp = Typage.typeof p in
    
    if !type_only then begin Typprinter.tprint_fichier tp; exit 0; end;
    
    let ap = (Adapt.adapter p) in
      begin
        (*Adapt.print_file ap;*)
        let sp = Simplify.simplify (ap) in
        if !simplify_only then begin Simpleprinter.print_fichier sp ; exit 0; end;
        let _ = GenCode.compile_program (Make_closures.transform (sp)) !ofile in
          exit 0
      end
    
    end
  with
    | Lexer.Lexing_error c ->
        (* Erreur lexicale. On récupère sa position absolue et
           on la convertit en numéro de ligne *)
        localisationAffiche (Lexing.lexeme_start_p buf, Lexing.lexeme_end_p buf);
        eprintf "lexing error: %s@." c;
        exit 1
    | Parser.Error ->
        (* Erreur syntaxique. On récupère sa position absolue et on la
           convertit en numéro de ligne *)
        localisationAffiche (Lexing.lexeme_start_p buf, Lexing.lexeme_end_p buf);
        eprintf "syntax error@.";
        exit 1
        
    | Typage.Typing_error (c,s) ->
        (* Erreur de type : on récupère les coordonnées dans c:loc*)
        localisationAffiche (c);
        eprintf "typing error: %s@." s;
        exit 1 
    (*| Alloc.VarUndef s-> 
        (* Erreur d'utilisation de variable pendant la compilation *)
        eprintf 
          "Erreur de compilation: la variable %s n'est pas definie@." s;
        exit 1*)
        

        

