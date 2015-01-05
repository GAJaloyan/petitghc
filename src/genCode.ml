module C = Closured

let elsenb = ref 0

let endifnb = ref 0

let nextElse () =
   incr elsenb;
   "if" ^ (string_of_int !elsenb)

let nextEndIf () =
   incr endifnb;
   "endif" ^ (string_of_int !endifnb)

let baseFunctions =
   label "force" ++
   lw t0 areg (0,a0)++
   bgt t0 4 "force_1" ++
   jr ra ++
   
   label "force_1" ++
   li t1 3 ++
   beq t0 t1 "force_2" ++
   lw a0 areg (4,a0) ++
   jr ra ++

   label force_2 ++
   push a0 ++
   push ra ++
   lw a1 areg (4,a0) ++
   lw t0 areg (4,a1) ++
   jalr t0 ++
   move a0 v0 ++
   jal "force" ++
   lw a1 areg (4,sp) ++
   sw a0 areg (4,a1) ++
   li t0 4 ++
   sw t0 areg (0,a1) ++
   lw ra areg (0,sp) ++
   popn 8 ++
   jr ra ++

   label "putChar" ++
   push fp ++
   push ra ++
   jal "force" ++
   li v0 11 ++
   push a0 ++
   lw a0 areg (4, a0) ++
   syscall ++
   pop a0 ++
   pop ra ++
   pop fp ++
   jr ra ++

   label "div" ++
   push ra ++
   push a1 ++
   jal force ++
   push a0 ++
   lw a1 areg (4,sp) ++
   move a0 a1 ++
   jal force ++
   lw t1 areg (4,a0) ++ (* $t1 = value of $a1 *)
   lw a0 areg (0,sp) ++
   lw t0 areg (4,a0) ++ (* $t0 = value of $a0 *)
   div t0 t0 t1 ++
   li a0 8 ++ (* bloc for the result *)
   li v0 9 ++
   syscall ++
   sw t0 areg (4,v0) ++
   li t0 0 ++
   sw t0 areg (0,v0) ++
   lw ra areg (8,sp) ++
   popn 12 ++
   jr ra ++

   label "rem" ++
   push ra ++
   push a1 ++
   jal force ++
   push a0 ++
   lw a1 areg (4, sp) ++
   move a0 a1 ++
   jal force ++
   lw t1 areg (4,a0) ++ (* $t1 = value of $a1 *)
   lw a0 areg (0,sp) ++
   lw t0 areg (4,a0) ++ (* $t0 = value of $a0 *)
   rem t0 t0 t1 ++
   li a0 8 ++ (* bloc for the result *)
   li v0 9 ++
   syscall ++
   sw t0 areg (4,v0) ++
   li t0 0 ++
   sw t0 areg (0,v0) ++
   lw ra areg (8,sp) ++
   popn 12 ++
   jr ra

let compile_expr = function
 | C.Evar v -> begin match v with
     | Vglobal x -> li v0 x
     | Vlocal i ->
        lw v0 areg (n*4, fp)
     | Vclos n ->
        lw v0 areg ((n+1)*4, a1)
     | Varg -> 
        move v0 a0 (* the current functions argument is in a0 *)
 | C.Eclos (f,vs) ->
     push a0 ++
     li a0 (4*((List.length vs) + 1)) ++
     li v0 9 ++
     la t0 f ++
     sw t0 areg (0,v0) ++
 | C.Eapp (e1,e2) ->
     let code_e1 = compile_expr e1
     and code_e2 = compile_expr e2 in
     code_e1 ++
     move a1 v0 ++
     code_e2 ++
     move a0 v0 ++
     lw t0 areg (0,a1) ++
     jalr t0
 | C.Ethunk e -> failwith "undefined"
 | C.Elet (bs,e) ->
     (List.fold_left
       (fun acc (i,e') ->
          acc ++
          compile_expr e' ++
          sw v0 areg (i,fp))
       nop
       bs) ++
     compile_expr e
 | C.Eif (e1,e2,e3) ->
     let code_e1 = compile_expr e1
     and code_e2 = compile_expr e2
     and code_e3 = compile_expr e3 in
     let else_lab = nextElse () and endif_lab = nextEndIf () in
     code_e1 ++
     lw t0 areg (4,v0) ++
     beqz t0 else_lab ++
     code_e2 ++
     j endif_lab ++
     label else_lab ++
     code_e3 ++
     label endif_lab (* v0 already contains the good value *)
 | C.Ecase (e1,e2,i1,i2,e3) -> failwith "undefined"
 | C.Edo es ->
     List.fold_left (++) (List.map (compile_expr es)) nop
 | C.Ereturn -> nop
 | C.Eneg -> failwith "undefined"
 | C.EbinOp (e1,o,e2) -> 
     compile_binop o e1 e2
 | C.Etrue ->
     li a0 8 ++
     li v0 9 ++
     syscall ++
     li t0 1 ++
     sw t0 areg (4,v0) ++
     li t0 3 ++
     sw t0 areg (0,v0) ++
     move a0 v0
 | C.Efalse ->
     li a0 8 ++
     li v0 9 ++
     syscall ++
     li t0 0 ++
     sw t0 areg (4,v0) ++
     li t0 3 ++
     sw t0 areg (0,v0) ++
     move a0 v0
 | C.Eint n ->
     li a0 8 ++
     li v0 9 ++
     syscall ++
     li t0 n ++
     sw t0 areg (4,v0) ++
     li t0 0 ++
     sw t0 areg (0,v0) ++
     move a0 v0
 | C.Echar c ->
     li a0 8 ++
     li v0 9 ++
     syscall ++
     "li $t0, 'c'" ++
     sw t0 areg (4,v0) ++
     li t0 1 ++
     sw t0 areg (0,v0) ++
     move a0 v0
 | C.EemptyList ->
     li a0 8 ++
     li v0 9 ++
     syscall ++
     li t0 0 ++
     sw t0 areg (4,v0) ++
     li t0 0 ++
     sw t0 areg (0,v0) ++
     move a0 v0

and compile_binop o e1 e2 = failwith "undefined"

and compile_decl (codefun, codemain) = function
 | C.Let (x,e) ->
     let code_e = compile_expr e in
     label x ++
     push ra ++
     push fp ++
     move fp sp ++
     code_e ++
     pop fp ++
     pop ra ++
     jr ra
 | C.Letfun (x,e) ->
     let code_e = compile_expr e in
     label x ++
     push ra ++
     push fp ++
     move fp sp ++
     code_e ++
     pop fp ++
     pop ra ++
     jr ra

let compile_program p ofile =
   let codefun, code = List.fold_left compile_decl (nop, nop) p in
   let p =
     { text =
        baseFunctions ++
        codefun
     }
   in
   let f = open_out ofile in
   let fmt = Format.formatter_of_out_channel f in
   Mips.print_program fmt p;
   fprint fmt "@?";
   close_out f
