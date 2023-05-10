open Yvm_lib

let () =
  let r_cls = Jparser.parse_class "Foo.class" in
  Jparser.show_raw_class r_cls |> print_endline;
  Array.iteri
    (fun i el ->
      print_int i;
      print_char ' ';
      Jparser.show_constant el |> print_endline)
    r_cls.constant_pool;
  let c_cls = Jparser.cook_class r_cls in
  c_cls |> Jparser.show_ckd_class |> print_endline;
  Jinterpreter.run c_cls
