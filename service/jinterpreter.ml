let run (c_cls : Jparser.ckd_class) =
  let main = List.assoc "main" c_cls.methods in
  let code = main.code in
  let pc = ref 0 in
  let stack = Stack.create () in
  let locals = Array.make main.max_locals 0 in
  while true do
    let opcode = code.[!pc] in
    let () =
      match opcode with
      | '\x10' (*bipush*) ->
          let byte = code.[!pc + 1] |> Char.code in
          Stack.push byte stack;
          pc := !pc + 2
      | '\x3c' (*istore_1*) ->
          locals.(1) <- Stack.pop stack;
          pc := !pc + 1
      | '\xb8' (*invokestatic*) ->
          let _idx = String.get_uint16_be code (!pc + 1) in
          failwith "invokestatic cannot be implemented yet"
      | o -> o |> Char.code |> Printf.sprintf "unknown opcode: 0x%x" |> failwith
    in
    ()
  done
