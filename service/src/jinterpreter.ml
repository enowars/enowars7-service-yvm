let run (c_cls : Jparser.ckd_class) (methods : (string * Jparser.meth) list) =
  let main =
    match List.assoc_opt "main" methods with
    | Some main -> main
    | None -> failwith "no main Method present"
  in
  let code = main.code in
  let pc = ref 0 in
  let stack = Stack.create () in
  let locals = Array.make main.max_locals 0 in
  let cp = c_cls.constant_pool in
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
          let cidx, ntidx =
            match cp.(_idx) with
            | Jparser.C_Methodref x -> (x.class_index, x.name_and_type_index)
            | _ -> failwith "expected Methodref"
          in
          let class_name_idx =
            match cp.(cidx) with
            | Jparser.C_Class x -> x.name_index
            | _ -> failwith "expected Class"
          in
          let klass =
            match cp.(class_name_idx) with
            | Jparser.C_Utf8 c -> c
            | _ -> failwith "expected Utf8"
          in
          print_endline klass;
          Jparser.show_constant cp.(cidx) |> print_endline;
          Jparser.show_constant cp.(ntidx) |> print_endline;
          failwith "foo"
      | o -> o |> Char.code |> Printf.sprintf "unknown opcode: 0x%x" |> failwith
    in
    ()
  done
