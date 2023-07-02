type pType = Jparser.primType [@@deriving show]

type frame = {
  code : string;
  pc : int;
  fstack : pType list;
  klass : Jparser.ckd_class;
  locals : pType array;
}
[@@deriving show]

type state = { sstack : frame list; pool : Classpool.t; name : string }

let npe_msg =
  "Though Exceptions are not implemented, but: https://youtu.be/bLHL75H_VEM"

let get_i16 code pc = String.get_int16_be code (pc + 1)

let rec check_inv_helper = function
  | ')' :: ret, [] -> Some ret
  | 'I' :: ds, _ :: ss -> check_inv_helper (ds, ss)
  | _, _ -> None

let get_args_str dstor =
  assert (dstor.[0] == '(');
  let i = String.rindex dstor ')' in
  let args = String.sub dstor 1 (i - 1) in
  let args = String.fold_right List.cons args [] in
  let rec rm_arr_br = function
    | '[' :: '[' :: cs -> rm_arr_br ('[' :: cs)
    | '[' :: _ :: cs -> '[' :: rm_arr_br cs
    | c :: cs -> c :: rm_arr_br cs
    | [] -> []
  in
  rm_arr_br args

let take_args args stack =
  let rec ta_helper args stack acc =
    match (args, stack) with
    | [], stack -> (stack, acc)
    | _, [] -> failwith "foo"
    | 'I' :: args, Jparser.P_Int i :: ss ->
        ta_helper args ss (Jparser.P_Int i :: acc)
    | 'I' :: args, Jparser.P_Char c :: ss ->
        ta_helper args ss (Jparser.P_Int (c |> Char.code |> Int32.of_int) :: acc)
    | 'C' :: args, Jparser.P_Char c :: ss ->
        ta_helper args ss (Jparser.P_Char c :: acc)
    | 'C' :: args, Jparser.P_Int i :: ss ->
        ta_helper args ss (Jparser.P_Char (i |> Int32.to_int |> Char.chr) :: acc)
    | '[' :: args, Jparser.P_Reference arr :: ss ->
        ta_helper args ss (Jparser.P_Reference arr :: acc)
    | _, _ -> failwith "foo"
  in
  let stack, racc = ta_helper args stack [] in
  (stack, racc)

let print_pType pt =
  let rec print_pType_h = function
    | Jparser.P_Int i -> i |> Int32.to_int |> Printf.printf "%d"
    | Jparser.P_Char c -> c |> Printf.printf "%c"
    | Jparser.P_Reference (Some arr) -> arr |> Array.iter print_pType_h
    | Jparser.P_Reference None -> print_string "nil"
    | _ -> failwith "cannot print this"
  in
  print_pType_h pt;
  print_newline ()

let run_native state _ name args =
  match name with
  | "print" ->
      List.iter print_pType args;
      state
  | "dump" ->
      state.pool |> Classpool.show |> print_endline;
      state
  | _ -> "native method '" ^ name ^ "' not implemented" |> failwith

let astore_n n locals = function
  | Jparser.P_Reference s :: ss ->
      locals.(n) <- Jparser.P_Reference s;
      ss
  | _ -> failwith "expected reference on stack"

let istore_n n locals = function
  | Jparser.P_Int i :: ss ->
      locals.(n) <- Jparser.P_Int i;
      ss
  | Jparser.P_Char c :: ss ->
      locals.(n) <- Jparser.P_Int (c |> Char.code |> Int32.of_int);
      ss
  | s :: _ -> s |> show_pType |> failwith
  | _ -> failwith "expected int on stack"

let null_on_stack = function
  | Jparser.P_Reference (Some _) :: stack -> (false, stack)
  | Jparser.P_Reference None :: stack -> (true, stack)
  | a :: _ -> show_pType a |> failwith
  | [] -> failwith "empty stack"

let cmp_on_stack cmp = function
  | Jparser.P_Int v2 :: Jparser.P_Int v1 :: stack ->
      (cmp (Int32.to_int v1) (Int32.to_int v2), stack)
  | a :: b :: _ ->
      a |> show_pType |> print_endline;
      b |> show_pType |> print_endline;
      failwith "foo"
  | _ -> failwith "foo"

let step state get_field
    (get_method :
      Classpool.t -> string -> string -> string * string -> Jparser.meth) =
  let { sstack; pool; _ } = state in
  let frame, frames =
    match sstack with
    | frame :: frames -> (frame, frames)
    | [] -> failwith "empty stack?!"
  in
  let { code; pc; fstack = stack; klass = c_cls; locals } = frame in
  let opcode = code.[pc] in
  let foo pc fstack =
    { state with sstack = { frame with pc; fstack } :: frames }
  in
  let branch cond =
    let take_branch, stack = cond stack in
    foo (if take_branch then pc + get_i16 code pc else pc + 3) stack
  in
  match opcode with
  | '\x01' (*aconst_null*) -> foo (pc + 1) (P_Reference None :: stack)
  | '\x02' (*iconst_m1*) -> foo (pc + 1) (P_Int (-1l) :: stack)
  | '\x03' (*iconst_0*) -> foo (pc + 1) (P_Int 0l :: stack)
  | '\x04' (*iconst_1*) -> foo (pc + 1) (P_Int 1l :: stack)
  | '\x05' (*iconst_2*) -> foo (pc + 1) (P_Int 2l :: stack)
  | '\x06' (*iconst_3*) -> foo (pc + 1) (P_Int 3l :: stack)
  | '\x07' (*iconst_4*) -> foo (pc + 1) (P_Int 4l :: stack)
  | '\x08' (*iconst_5*) -> foo (pc + 1) (P_Int 5l :: stack)
  | '\x10' (*bipush*) ->
      let byte = code.[pc + 1] |> Char.code |> Int32.of_int in
      foo (pc + 2) (P_Int byte :: stack)
  | '\x11' (*sipush*) ->
      foo (pc + 3) (P_Int (get_i16 code pc |> Int32.of_int) :: stack)
  | '\x12' (*ldc*) ->
      let idx = code.[pc + 1] |> Char.code in
      let pc, s =
        match c_cls.constant_pool.(idx) with
        | C_Integer i ->
            let i = Jparser.P_Int i in
            (pc + 2, i :: stack)
        | x -> Jparser.show_constant x |> ( ^ ) "unexpeced " |> failwith
      in
      foo pc s
  | '\x15' (*iload*) ->
      let idx = code.[pc + 1] |> Char.code in
      foo (pc + 2) (locals.(idx) :: stack)
  | '\x19' (*aload*) ->
      let idx = code.[pc + 1] |> Char.code in
      foo (pc + 2) (locals.(idx) :: stack)
  | '\x1a' (*iload_0*) -> foo (pc + 1) (locals.(0) :: stack)
  | '\x1b' (*iload_1*) -> foo (pc + 1) (locals.(1) :: stack)
  | '\x1c' (*iload_2*) -> foo (pc + 1) (locals.(2) :: stack)
  | '\x1d' (*iload_3*) -> foo (pc + 1) (locals.(3) :: stack)
  | '\x2a' (*aload_0*) -> foo (pc + 1) (locals.(0) :: stack)
  | '\x2b' (*aload_1*) -> foo (pc + 1) (locals.(1) :: stack)
  | '\x2c' (*aload_2*) -> foo (pc + 1) (locals.(2) :: stack)
  | '\x2d' (*aload_3*) -> foo (pc + 1) (locals.(3) :: stack)
  | '\x32' (*aaload*) ->
      let ss =
        match stack with
        | P_Int idx :: P_Reference (Some arr) :: ss ->
            let a =
              match arr.(Int32.to_int idx) with
              | Jparser.P_Reference a -> a
              | _ -> failwith "expected arr array"
            in
            Jparser.P_Reference a :: ss
        | P_Int _ :: P_Reference None :: _ -> failwith npe_msg
        | _ -> failwith "foo"
      in
      foo (pc + 1) ss
  | '\x34' (*caload*) ->
      let ss =
        match stack with
        | P_Int idx :: P_Reference (Some arr) :: ss ->
            let c =
              match arr.(Int32.to_int idx) with
              | P_Char c -> c
              | _ -> failwith "expected char array"
            in
            Jparser.P_Char c :: ss
        | P_Int _ :: P_Reference None :: _ -> failwith npe_msg
        | _ -> failwith "foo"
      in
      foo (pc + 1) ss
  | '\x36' (*istore*) ->
      let idx = code.[pc + 1] |> Char.code in
      foo (pc + 2) (istore_n idx locals stack)
  | '\x3a' (*astore*) ->
      let idx = code.[pc + 1] |> Char.code in
      foo (pc + 2) (astore_n idx locals stack)
  | '\x3b' (*istore_0*) -> foo (pc + 1) (istore_n 0 locals stack)
  | '\x3c' (*istore_1*) -> foo (pc + 1) (istore_n 1 locals stack)
  | '\x3d' (*istore_2*) -> foo (pc + 1) (istore_n 2 locals stack)
  | '\x3e' (*istore_3*) -> foo (pc + 1) (istore_n 3 locals stack)
  | '\x4b' (*astore_0*) -> foo (pc + 1) (astore_n 0 locals stack)
  | '\x4c' (*astore_1*) -> foo (pc + 1) (astore_n 1 locals stack)
  | '\x4d' (*astore_2*) -> foo (pc + 1) (astore_n 2 locals stack)
  | '\x4e' (*astore_3*) -> foo (pc + 1) (astore_n 3 locals stack)
  | '\x53' (*aastore*) ->
      let ss =
        match stack with
        | P_Reference a :: P_Int idx :: P_Reference (Some arr) :: ss ->
            arr.(Int32.to_int idx) <- P_Reference a;
            ss
        | P_Reference _ :: P_Int _ :: P_Reference None :: _ -> failwith npe_msg
        | _ -> failwith "expected reference on stack"
      in
      foo (pc + 1) ss
  | '\x55' (*castore*) ->
      let ss =
        match stack with
        | P_Char c :: P_Int idx :: P_Reference (Some arr) :: ss ->
            arr.(Int32.to_int idx) <- P_Char c;
            ss
        | P_Int c :: P_Int idx :: P_Reference (Some arr) :: ss ->
            arr.(Int32.to_int idx) <- P_Char (c |> Int32.to_int |> Char.chr);
            ss
        | P_Char _ :: P_Int _ :: P_Reference None :: _ -> failwith npe_msg
        | P_Int _ :: P_Int _ :: P_Reference None :: _ -> failwith npe_msg
        | _ -> failwith "expected char/int, int, reference on stack"
      in
      foo (pc + 1) ss
  | '\x57' (*pop*) -> foo (pc + 1) (List.tl stack)
  | '\x59' (*dup*) ->
      let h = List.hd stack in
      foo (pc + 1) (h :: stack)
  | '\x60' (*iadd*) ->
      let stack =
        match stack with
        | P_Int a :: P_Int b :: ss ->
            let r = Jparser.P_Int (Int32.add a b) in
            r :: ss
        | _ -> failwith "expected two ints on stack"
      in
      foo (pc + 1) stack
  | '\x84' (*iinc*) ->
      let idx = code.[pc + 1] |> Char.code in
      let cnst = code.[pc + 2] |> Char.code in
      let v =
        match locals.(idx) with
        | Jparser.P_Int i ->
            Jparser.P_Int (Int32.to_int i + cnst |> Int32.of_int)
        | Jparser.P_Char c -> Jparser.P_Int (Char.code c + cnst |> Int32.of_int)
        | s -> s |> show_pType |> failwith
      in
      locals.(idx) <- v;
      foo (pc + 3) stack
  | '\x9f' (*if_icmpeq*) -> branch (cmp_on_stack ( = ))
  | '\xa0' (*if_icmpne*) -> branch (cmp_on_stack ( != ))
  | '\xa1' (*if_icmplt*) -> branch (cmp_on_stack ( < ))
  | '\xa2' (*if_icmpge*) -> branch (cmp_on_stack ( >= ))
  | '\xa3' (*if_icmpgt*) -> branch (cmp_on_stack ( > ))
  | '\xa4' (*if_icmple*) -> branch (cmp_on_stack ( <= ))
  | '\xa7' (*goto*) -> branch (fun s -> (true, s))
  | '\xac' (*ireturn*) ->
      let i =
        match stack with
        | i :: _ -> i
        | [] -> failwith "ireturn: expected int on stack"
      in
      let frames =
        match frames with
        | f :: fs -> { f with fstack = i :: f.fstack } :: fs
        | [] -> failwith "foo"
      in
      { state with sstack = frames }
  | '\xb1' (*return*) -> { state with sstack = frames }
  | '\xb2' (*getstatic*) ->
      let idx = get_i16 code pc in
      let klass, (name, jtype) =
        match c_cls.ckd_cp.(idx) with
        | CKD_Field { klass; name_and_type } -> (klass, name_and_type)
        | _ -> failwith "expected field"
      in
      let f = get_field pool c_cls.name klass (name, jtype) in
      foo (pc + 3) (!f :: stack)
  | '\xb3' (*putstatic*) ->
      let idx = get_i16 code pc in
      let klass, (name, jtype) =
        match c_cls.ckd_cp.(idx) with
        | CKD_Field { klass; name_and_type } -> (klass, name_and_type)
        | _ -> failwith "expected field"
      in
      let f = get_field pool c_cls.name klass (name, jtype) in
      let v, stack =
        match (jtype, stack) with
        | "I", P_Int v :: ss -> (Jparser.P_Int v, ss)
        | s, P_Reference r :: ss when String.get s 0 = '[' ->
            (Jparser.P_Reference r, ss)
        | t, v :: _ -> "putstatic (" ^ t ^ ", " ^ show_pType v ^ ")" |> failwith
        | _, [] -> "expected sth on stack" |> failwith
      in
      f := v;
      foo (pc + 3) stack
  | '\xb8' (*invokestatic*) -> (
      let idx = get_i16 code pc in
      let klass, (name, jtype) =
        match c_cls.ckd_cp.(idx) with
        | CKD_Method { klass; name_and_type } -> (klass, name_and_type)
        | _ -> failwith "expected method"
      in
      let args = get_args_str jtype in
      let fstack, args = take_args args stack in
      match get_method pool c_cls.name klass (name, jtype) with
      | Jparser.NativeMeth ->
          let state = foo (pc + 3) fstack in
          run_native state klass name args
      | Jparser.LocalMeth f ->
          let klass =
            match List.assoc_opt klass !pool with
            | Some x -> x
            | None -> failwith "class should have been loaded"
          in
          let locals = Array.make f.max_locals Jparser.P_ReturnAddress in
          List.iteri (Array.set locals) args;
          let new_frame =
            { code = f.code; pc = 0; fstack = []; klass; locals }
          in
          {
            state with
            sstack = new_frame :: { frame with pc = pc + 3; fstack } :: frames;
          })
  | '\xbc' (*newarray*) ->
      let atype = code.[pc + 1] |> Char.code in
      assert (atype = 5);
      (*only char array supported*)
      let count, stack =
        match stack with
        | P_Int count :: stack -> (Int32.to_int count, stack)
        | a :: _ -> show_pType a |> failwith
        | [] -> failwith "empty stack"
      in
      let r = Array.make count (Jparser.P_Char (Char.chr 0)) in
      foo (pc + 2) (Jparser.P_Reference (Some r) :: stack)
  | '\xbd' (*anewarray*) ->
      let count, stack =
        match stack with
        | P_Int count :: stack -> (Int32.to_int count, stack)
        | a :: _ -> show_pType a |> failwith
        | [] -> failwith "empty stack"
      in
      let r = Array.make count (Jparser.P_Reference None) in
      foo (pc + 3) (Jparser.P_Reference (Some r) :: stack)
  | '\xbe' (*arraylength*) ->
      let length, stack =
        match stack with
        | P_Reference (Some arr) :: stack -> (Array.length arr, stack)
        | P_Reference None :: _ -> failwith npe_msg
        | a :: _ -> show_pType a |> failwith
        | [] -> failwith "empty stack"
      in
      foo (pc + 1) (P_Int (Int32.of_int length) :: stack)
  | '\xc7' (*ifnonnull*) ->
      let non_null_on_stack s =
        let is_true, s = null_on_stack s in
        (not is_true, s)
      in
      branch non_null_on_stack
  | '\xc8' (*ifnull*) -> branch null_on_stack
  | o -> o |> Char.code |> Printf.sprintf "unknown opcode: 0x%x" |> failwith

let rec run (c_cls : Jparser.ckd_class) (name, jtype) =
  let main =
    match List.assoc_opt (name, jtype) c_cls.meths with
    | Some (Jparser.LocalMeth main) -> main
    | _ -> failwith ("Method " ^ name ^ jtype ^ " not found")
  in
  let cut_last_char s =
    let len = String.length s in
    String.sub s 0 (len - 1)
  in
  let code =
    if name = "main" && jtype = "([Ljava/lang/String;)V" then
      match List.assoc_opt ("<clinit>", "()V") c_cls.meths with
      | Some (Jparser.LocalMeth static) -> cut_last_char static.code ^ main.code
      | _ -> main.code
    else main.code
  in
  let locals = Array.make main.max_locals Jparser.P_ReturnAddress in
  let frame = { code; pc = 0; fstack = []; klass = c_cls; locals } in
  let pool = ref [ (c_cls.name, c_cls) ] in
  let state = ref { sstack = [ frame ]; pool; name } in
  let get_field = Classpool.get_field run in
  let get_method = Classpool.get_method run in
  let i = ref 0 in
  while !state.sstack != [] do
    let _ =
      if !i > 10000 then failwith "more than 10k instructions: aborting"
      else incr i
    in
    state := step !state get_field get_method
  done
