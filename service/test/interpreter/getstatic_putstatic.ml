open Yvm_lib

let _ =
  (Jparser.parse_class "Foo.class" |> Jparser.cook_class |> Jinterpreter.run)
    ("main", "([Ljava/lang/String;)V")
