open Yvm_lib

let () =
  Printexc.record_backtrace true;
  Random.self_init ();
  try
    let klass =
      if Array.length Sys.argv > 1 then Sys.argv.(1)
      else Exc.fail_usage "expecting class file as first arg"
    in
    let klass =
      if String.ends_with ~suffix:".class" klass then klass
      else Exc.fail_usage "file doesn't end with '.class'"
    in
    let r_cls = Jparser.parse_class klass in
    let c_cls = Jparser.cook_class r_cls in
    (* TODO call <clinit> of main class *)
    Jinterpreter.run c_cls ("main", "([Ljava/lang/String;)V")
  with Exc.Usage_error msg ->
    let stack = Printexc.get_backtrace () in
    Printf.eprintf "Seems like you misused yvm: '%s'\n%s\n" msg stack
