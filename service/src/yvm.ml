open Yvm_lib

let () =
  let klass =
    if Array.length Sys.argv > 1 then Sys.argv.(1)
    else failwith "expecting class file as first arg"
  in
  let klass =
    if String.ends_with ~suffix:".class" klass then klass
    else failwith "file doesn't end with '.class'"
  in
  let r_cls = Jparser.parse_class klass in
  let c_cls = Jparser.cook_class r_cls in
  (* TODO call <clinit> of main class *)
  Jinterpreter.run c_cls ("main", "([Ljava/lang/String;)V")
