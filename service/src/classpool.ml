type pool_entry = Method of Jparser.meth | Int of int
type klass = Jparser.ckd_class
type t = (string * klass) list ref

let rec get_field run_callback (t : t) (klass : string) (nat : string * string)
    =
  match List.assoc_opt klass !t with
  | Some kpool -> (
      match List.assoc_opt nat kpool.fields with
      | Some entry -> entry
      | None -> failwith "invalid nat into loaded class")
  | None ->
      let ckd_cls =
        Jparser.parse_class (klass ^ ".class") |> Jparser.cook_class
      in
      t := (klass, ckd_cls) :: !t;
      run_callback ckd_cls ("<clinit>", "()V");
      get_field run_callback t klass nat

let show (t : t) =
  List.map
    (fun (kname, klass) -> kname ^ "\n" ^ Jparser.show_ckd_class klass)
    !t
  |> String.concat "\n"
