type pool_entry = Method of Jparser.meth | Int of int
type klass = Jparser.ckd_class
type t = (string * klass) list ref

let rec get_field run_callback (t : t) (caller : string) (klass : string)
    (nat : string * string) =
  match List.assoc_opt klass !t with
  | Some kpool -> (
      match List.assoc_opt nat kpool.fields with
      | Some (_, entry) -> entry
      | None -> failwith "invalid nat into loaded class")
  | None ->
      let ckd_cls =
        Jparser.parse_class (klass ^ ".class") |> Jparser.cook_class
      in
      t := (klass, ckd_cls) :: !t;
      let () =
        match List.assoc_opt ("<clinit>", "()V") ckd_cls.meths with
        | Some _ -> run_callback ckd_cls ("<clinit>", "()V")
        | None -> ()
      in
      get_field run_callback t caller klass nat

let rec get_method run_callback (t : t) (caller : string) (klass : string)
    (nat : string * string) =
  match List.assoc_opt klass !t with
  | Some kpool -> (
      match List.assoc_opt nat kpool.meths with
      | Some meth -> meth
      | None -> failwith "invalid nat into loaded class")
  | None ->
      let ckd_cls =
        Jparser.parse_class (klass ^ ".class") |> Jparser.cook_class
      in
      t := (klass, ckd_cls) :: !t;
      let () =
        match List.assoc_opt ("<clinit>", "()V") ckd_cls.meths with
        | Some _ -> run_callback ckd_cls ("<clinit>", "()V")
        | None -> ()
      in
      get_method run_callback t caller klass nat

let show (t : t) =
  List.map
    (fun (kname, klass) -> kname ^ "\n" ^ Jparser.show_ckd_class klass)
    !t
  |> String.concat "\n"
