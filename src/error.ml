(* this file mainly fragments from the error utilities functions found
 * in the minijazz compiler *)
open Lexing

exception SyntaxError of string
exception SemantError of string
exception TypeError   of string

type location =
    Loc of position (* Position of the first character *)
         * position (* Position of the next character following the last one *)

let error_prompt = ">"

let ifile = ref ""

(** Print [n] times char [c] on [oc]. *)
let prints_n_chars ff n c = for i = 1 to n do Format.pp_print_char ff c done

(** Prints out to [oc] a line designed to be printed under [line] from file [ic]
 * underlining from char [first] to char [last] with char [ch].
 * [line] is the index of the first char of line. *)
let underline_line ic ff ch line first last =
    let c = ref ' '
    and f = ref first
    and l = ref (last - first) in
    ( try
      seek_in ic line;
      Format.pp_print_string ff error_prompt;
      while c := input_char ic; !c != '\n' do
          if !f > 0 then begin
              f := !f - 1;
              Format.pp_print_char ff (if !c == '\t' then !c else ' ')
          end
          else if !l > 0 then begin
              l := !l - 1;
              Format.pp_print_char ff (if !c == '\t' then !c else ch)
          end
          else ()
      done
    with End_of_file ->
        if !f = 0 && !l > 0 then prints_n_chars ff 5 ch )

let copy_lines nl ic ff prompt =
    for i = 1 to nl do
        Format.pp_print_string ff prompt;
        (try Format.pp_print_string ff (input_line ic)
        with End_of_file -> Format.pp_print_string ff "<EOF>");
        Format.fprintf ff "@\n"
    done

let copy_chunk p1 p2 ic ff =
    try for i = p1 to p2-1 do Format.pp_print_char ff (input_char ic) done
    with End_of_file -> Format.pp_print_string ff "<EOF>"

let skip_lines n ic =
    try for i = 1 to n do
        let _ = input_line ic in ()
    done
    with End_of_file -> ()

let set_file chaine = 
    ifile := chaine

let print_location ff (Loc(p1,p2)) =
    let n1 = p1.pos_cnum - p1.pos_bol in (* character number *)
    let n2 = p2.pos_cnum - p2.pos_bol +1 in
    let np1 = p1.pos_cnum in (* character position *)
    let np2 = p2.pos_cnum in
    let l1 = p1.pos_lnum in (* line number *)
    let l2 = p2.pos_lnum in
    let lp1 = p1.pos_bol in (* line position *)
    let lp2 = p2.pos_bol in
    let f1 = !ifile in (* file name *)
    if l2 > l1 then
        Format.fprintf ff "File \"%s\", line %d-%d, characters %d-%d:\n" f1 l1 l2 n1 n2
    else
        Format.fprintf ff "File \"%s\", line %d, characters %d-%d:\n" f1 l1 n1 n2;
    (* Output source code *)
    try
        let ic = open_in f1 in
        
        if l1 == l2 then (
            (* Only one line : copy full line and underline *)
            seek_in ic lp1;
            copy_lines 1 ic ff ">";
            underline_line ic ff '^' lp1 n1 n2 )
        else (
            underline_line ic ff '.' lp1 0 n1; (* dots until n1 *)
            seek_in ic np1;
            (* copy the end of the line l1 after the dots *)
            copy_lines 1 ic ff "";
            if l2 - l1 <= 8 then
                (* copy the 6 or less middle lines *)
                copy_lines (l2-l1-1) ic ff ">"
            else (
                (* sum up the middle lines to 6 *)
                copy_lines 3 ic ff ">";
                Format.fprintf ff "............@\n";
                skip_lines (l2-l1-7) ic; (* skip middle lines *)
                copy_lines 3 ic ff ">"
            );
            Format.fprintf ff ">";
            copy_chunk lp2 np2 ic ff; (* copy interesting begining of l2 *)
        )
    with Sys_error _ -> ();
    Format.fprintf ff "@.\n"
