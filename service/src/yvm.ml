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
  Jparser.show_raw_class r_cls |> print_endline;
  Array.iteri
    (fun i el ->
      print_int i;
      print_char ' ';
      Jparser.show_constant el |> print_endline)
    r_cls.constant_pool;
  let c_cls = Jparser.cook_class r_cls in
  c_cls |> Jparser.show_ckd_class |> print_endline;
  (* TODO call <clinit> of main class *)
  Jinterpreter.run c_cls ("main", "([Ljava/lang/String;)V")
