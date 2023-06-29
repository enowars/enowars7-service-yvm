type frame = {
  code : string;
  pc : int;
  fstack : int list;
  klass : Jparser.ckd_class;
  locals : int array;
}
[@@deriving show]

type state = {
  sstack : frame list;
  halt : bool ref;
  pool : Classpool.t;
  name : string;
}

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

let step state get_field
    (get_method :
      Classpool.t -> string -> string -> string * string -> Jparser.meth) =
  let { sstack; halt; pool; name } = state in
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
  | '\x04' (*iconst_1*) -> foo (pc + 1) (1 :: stack)
  | '\x08' (*iconst_5*) -> foo (pc + 1) (5 :: stack)
  | '\x10' (*bipush*) ->
      let byte = code.[pc + 1] |> Char.code in
      foo (pc + 2) (byte :: stack)
  | '\x11' (*sipush*) -> foo (pc + 3) (get_u2 code pc :: stack)
  | '\x12' (*ldc*) ->
      let idx = code.[pc + 1] |> Char.code in
      let pc, s =
        match c_cls.constant_pool.(idx) with
        | C_Integer i -> (pc + 2, Int32.to_int i :: stack)
        | x -> Jparser.show_constant x |> ( ^ ) "unexpeced " |> failwith
      in
      foo pc s
  | '\x19' (*aload*) ->
      let lidx = code.[pc + 1] |> Char.code in
      foo (pc + 2) (locals.(lidx) :: stack)
  | '\x1a' (*iload_0*) -> foo (pc + 1) (locals.(0) :: stack)
  | '\x1b' (*iload_1*) -> foo (pc + 1) (locals.(1) :: stack)
  | '\x1c' (*iload_2*) -> foo (pc + 1) (locals.(2) :: stack)
  | '\x2a' (*aload_0*) -> foo (pc + 1) (locals.(0) :: stack)
  | '\x3c' (*istore_1*) ->
      let ss =
        match stack with
        | s :: ss ->
            locals.(1) <- s;
            ss
        | [] -> failwith "extected int on stack"
      in
      foo (pc + 1) ss
  | '\x3d' (*istore_2*) ->
      let ss =
        match stack with
        | s :: ss ->
            locals.(2) <- s;
            ss
        | [] -> failwith "expected int on stack"
      in
      foo (pc + 1) ss
  | '\x57' (*pop*) -> foo (pc + 1) (List.tl stack)
  | '\x60' (*iadd*) ->
      let stack =
        match stack with
        | a :: b :: ss -> (a + b) :: ss
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
      halt := true;
      { state with sstack = frames }
  | '\xb2' (*getstatic*) ->
      let idx = get_u2 code pc in
      let klass, (name, jtype) =
        match c_cls.ckd_cp.(idx) with
        | CKD_Field { klass; name_and_type } -> (klass, name_and_type)
        | _ -> failwith "expected field"
      in
      let f = get_field pool c_cls.name klass (name, jtype) in
      let v =
        match !f with
        | Jparser.Int i -> i
        | _ -> failwith "only int implemented"
      in
      foo (pc + 3) (Int32.to_int v :: stack)
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
        | "I", i :: ss -> (Jparser.Int (Int32.of_int i), ss)
        | _ -> failwith "yaoawhfahw"
      in
      f := v;
      foo (pc + 3) stack
  | '\xb8' (*invokestatic*) ->
      let idx = get_u2 code pc in
      let klass, (name, jtype) =
        match c_cls.ckd_cp.(idx) with
        | CKD_Method { klass; name_and_type } -> (klass, name_and_type)
        | _ -> failwith "expected method"
      in
      let f =
        match get_method pool c_cls.name klass (name, jtype) with
        | Jparser.NativeMeth -> failwith "foo"
        | Jparser.LocalMeth f -> f
      in
      let args = get_args_str jtype in
      let klass =
        match List.assoc_opt klass !pool with
        | Some x -> x
        | None -> failwith "class should have been loaded"
      in
      let locals = Array.make f.max_locals 0 in
      let args = String.fold_right List.cons args [] in
      let fstack, args = take_args args stack in
      List.iteri (Array.set locals) args;
      let new_frame = { code = f.code; pc = 0; fstack = []; klass; locals } in
      {
        state with
        sstack = new_frame :: { frame with pc = pc + 3; fstack } :: frames;
      }
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
  let locals = Array.make main.max_locals 0 in
  let frame = { code; pc = 0; fstack = []; klass = c_cls; locals } in
  let halt = ref false in
  let pool = ref [ (c_cls.name, c_cls) ] in
  let state = ref { sstack = [ frame ]; halt; pool; name } in
  let get_field = Classpool.get_field run in
  let get_method = Classpool.get_method run in
  while not !(!state.halt) do
    state := step !state get_field get_method
  done
