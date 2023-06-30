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

let get_u2 code pc =
  let b1 = (code.[pc + 1] |> Char.code) lsl 8 in
  let b2 = code.[pc + 2] |> Char.code in
  b1 lor b2

let rec check_inv_helper = function
  | ')' :: ret, [] -> Some ret
  | 'I' :: ds, _ :: ss -> check_inv_helper (ds, ss)
  | _, _ -> None

let get_args_str dstor =
  assert (dstor.[0] == '(');
  let i = String.rindex dstor ')' in
  String.sub dstor 1 (i - 1)

let take_args args stack =
  let rec ta_helper args stack acc =
    match (args, stack) with
    | [], stack -> (stack, acc)
    | _, [] -> failwith "foo"
    | 'I' :: args, s :: ss -> ta_helper args ss (s :: acc)
    | _, _ -> failwith "foo"
  in
  let stack, racc = ta_helper args stack [] in
  (stack, racc)

let print_pType = function
  | Jparser.P_Int i -> i |> Int32.to_int |> Printf.printf "%d\n"
  | _ -> failwith "cannot print this"

let run_native state _ name args =
  match name with
  | "print" ->
      List.iter print_pType args;
      state
  | _ -> "native method '" ^ name ^ "' not implemented" |> failwith

let step state get_field
    (get_method :
      Classpool.t -> string -> string -> string * string -> Jparser.meth) =
  let { sstack; pool; name } = state in
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
  match opcode with
  | '\x04' (*iconst_1*) -> foo (pc + 1) (P_Int 1l :: stack)
  | '\x08' (*iconst_5*) -> foo (pc + 1) (P_Int 5l :: stack)
  | '\x10' (*bipush*) ->
      let byte = code.[pc + 1] |> Char.code |> Int32.of_int in
      foo (pc + 2) (P_Int byte :: stack)
  | '\x11' (*sipush*) ->
      foo (pc + 3) (P_Int (get_u2 code pc |> Int32.of_int) :: stack)
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
  | '\x19' (*aload*) -> failwith "aload not implemented"
  | '\x1a' (*iload_0*) -> foo (pc + 1) (locals.(0) :: stack)
  | '\x1b' (*iload_1*) -> foo (pc + 1) (locals.(1) :: stack)
  | '\x1c' (*iload_2*) -> foo (pc + 1) (locals.(2) :: stack)
  | '\x2a' (*aload_0*) -> failwith "aload_0 not implemented"
  | '\x3c' (*istore_1*) ->
      let ss =
        match stack with
        | P_Int s :: ss ->
            locals.(1) <- P_Int s;
            ss
        | _ -> failwith "extected int on stack"
      in
      foo (pc + 1) ss
  | '\x3d' (*istore_2*) ->
      let ss =
        match stack with
        | P_Int s :: ss ->
            locals.(2) <- P_Int s;
            ss
        | _ -> failwith "expected int on stack"
      in
      foo (pc + 1) ss
  | '\x57' (*pop*) -> foo (pc + 1) (List.tl stack)
  | '\x60' (*iadd*) ->
      let stack =
        match stack with
        | P_Int a :: P_Int b :: ss ->
            let r = Jparser.P_Int (Int32.add a b) in
            r :: ss
        | _ -> failwith "expected two ints on stack"
      in
      foo (pc + 1) stack
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
  | '\xb1' (*return*) ->
      if name = "main" then pool |> Classpool.show |> print_endline else ();
      { state with sstack = frames }
  | '\xb2' (*getstatic*) ->
      let idx = get_u2 code pc in
      let klass, (name, jtype) =
        match c_cls.ckd_cp.(idx) with
        | CKD_Field { klass; name_and_type } -> (klass, name_and_type)
        | _ -> failwith "expected field"
      in
      let f = get_field pool c_cls.name klass (name, jtype) in
      foo (pc + 3) (!f :: stack)
  | '\xb3' (*putstatic*) ->
      let idx = get_u2 code pc in
      let klass, (name, jtype) =
        match c_cls.ckd_cp.(idx) with
        | CKD_Field { klass; name_and_type } -> (klass, name_and_type)
        | _ -> failwith "expected field"
      in
      let f = get_field pool c_cls.name klass (name, jtype) in
      let v, stack =
        match (jtype, stack) with
        | "I", P_Int v :: ss -> (Jparser.P_Int v, ss)
        | t, v :: _ -> "putstatic (" ^ t ^ ", " ^ show_pType v ^ ")" |> failwith
        | _, [] -> "expected sth on stack" |> failwith
      in
      f := v;
      foo (pc + 3) stack
  | '\xb8' (*invokestatic*) -> (
      let idx = get_u2 code pc in
      let klass, (name, jtype) =
        match c_cls.ckd_cp.(idx) with
        | CKD_Method { klass; name_and_type } -> (klass, name_and_type)
        | _ -> failwith "expected method"
      in
      let args = get_args_str jtype in
      let args = String.fold_right List.cons args [] in
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
      let r = Bytes.create count in
      foo (pc + 2) (Jparser.P_Reference r :: stack)
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
