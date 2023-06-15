open Yvm_lib

let () =
  let klass =
    match Sys.argv with
    | [| _; klass |] ->
        if String.ends_with ~suffix:".class" klass then klass
        else failwith "file doesn't end with '.class'"
    | _ -> failwith "expecting a single class file as arg"
  in
  let r_cls = Jparser.parse_class klass in
  let c_cls = Jparser.cook_class r_cls in
  (* TODO call <clinit> of main class *)
  Jinterpreter.run c_cls ("main", "([Ljava/lang/String;)V")
