open Jparser

let () =
  let r_cls = parse_class "Foo.class" in
  show_raw_class r_cls |> print_endline;
  Array.iteri
    (fun i el ->
      print_int i;
      print_char ' ';
      show_constant el |> print_endline)
    r_cls.constant_pool;
  let c_cls = cook_class r_cls in
  c_cls |> show_ckd_class |> print_endline;
  Jinterpreter.run c_cls
