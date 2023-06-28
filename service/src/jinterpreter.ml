type frame = {
  code : string;
  pc : int;
  fstack : int Stack.t;
  klass : Jparser.ckd_class;
  locals : int array;
}

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
  let pc =
    match opcode with
    | '\x04' (*iconst_1*) ->
        Stack.push 1 stack;
        pc + 1
    | '\x08' (*iconst_5*) ->
        Stack.push 5 stack;
        pc + 1
    | '\x10' (*bipush*) ->
        let byte = code.[pc + 1] |> Char.code in
        Stack.push byte stack;
        pc + 2
    | '\x11' (*sipush*) ->
        Stack.push (get_u2 code pc) stack;
        pc + 3
    | '\x12' (*ldc*) ->
        let idx = code.[pc + 1] |> Char.code in
        let () =
          match c_cls.constant_pool.(idx) with
          | C_Integer i -> Stack.push (Int32.to_int i) stack
          | x -> Jparser.show_constant x |> ( ^ ) "unexpeced " |> failwith
        in
        pc + 2
    | '\x19' (*aload*) ->
        let lidx = code.[pc + 1] |> Char.code in
        Stack.push locals.(lidx) stack;
        pc + 2
    | '\x2a' (*aload_0*) ->
        Stack.push locals.(0) stack;
        pc + 1
    | '\x3c' (*istore_1*) ->
        locals.(1) <- Stack.pop stack;
        pc + 1
    | '\x60' (*iadd*) ->
        let a = Stack.pop stack in
        let b = Stack.pop stack in
        Stack.push (a + b) stack;
        pc + 1
    | '\xb1' (*return*) ->
        if name = "main" then pool |> Classpool.show |> print_endline else ();
        halt := true;
        -1
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
        Stack.push (Int32.to_int v) stack;
        pc + 3
    | '\xb3' (*putstatic*) ->
        let idx = get_u2 code pc in
        let klass, (name, jtype) =
          match c_cls.ckd_cp.(idx) with
          | CKD_Field { klass; name_and_type } -> (klass, name_and_type)
          | _ -> failwith "expected field"
        in
        let f = get_field pool c_cls.name klass (name, jtype) in
        let v =
          match jtype with
          | "I" -> Jparser.Int (Stack.pop stack |> Int32.of_int)
          | _ -> failwith "yaoawhfahw"
        in
        f := v;
        pc + 3
    | '\xb8' (*invokestatic*) ->
        let idx = get_u2 code pc in
        let klass, (name, jtype) =
          match c_cls.ckd_cp.(idx) with
          | CKD_Method { klass; name_and_type } -> (klass, name_and_type)
          | _ -> failwith "expected method"
        in
        let f = get_method pool c_cls.name klass (name, jtype) in
        let args = get_args_str jtype in
        let klass =
          match List.assoc_opt klass !pool with
          | Some x -> x
          | None -> failwith "class should have been loaded"
        in
        let locals = Array.make f.max_locals 0 in
        let lidx = ref 0 in
        let pop_and_set_arg c =
          let e = Stack.pop stack in
          locals.(!lidx) <- e;
          let () =
            match (c, e) with
            | 'I', _ -> lidx := !lidx + 1
            | _ -> failwith "foo"
          in
          ()
        in
        String.iter pop_and_set_arg args;
        let new_frame =
          { code = f.code; pc = 0; fstack = Stack.create (); klass; locals }
        in
        pc + 3
    | o -> o |> Char.code |> Printf.sprintf "unknown opcode: 0x%x" |> failwith
  in
  { state with sstack = { frame with pc } :: frames }

let rec run (c_cls : Jparser.ckd_class) (name, jtype) =
  let main =
    match List.assoc_opt (name, jtype) c_cls.meths with
    | Some main -> main
    | None -> failwith ("Method " ^ name ^ jtype ^ " not found")
  in
  let cut_last_char s =
    let len = String.length s in
    String.sub s 0 (len - 1)
  in
  let code =
    if name = "main" && jtype = "([Ljava/lang/String;)V" then
      match List.assoc_opt ("<clinit>", "()V") c_cls.meths with
      | Some static -> cut_last_char static.code ^ main.code
      | None -> main.code
    else main.code
  in
  let fstack = Stack.create () in
  let locals = Array.make main.max_locals 0 in
  let frame = { code; pc = 0; fstack; klass = c_cls; locals } in
  let halt = ref false in
  let pool = ref [ (c_cls.name, c_cls) ] in
  let state = ref { sstack = [ frame ]; halt; pool; name } in
  let get_field = Classpool.get_field run in
  let get_method = Classpool.get_method run in
  while not !(!state.halt) do
    state := step !state get_field get_method
  done
