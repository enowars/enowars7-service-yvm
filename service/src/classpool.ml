type pool_entry = Method of Jparser.meth | Int of int
type klass = Jparser.ckd_class
type t = (string * klass) list ref

let rec get_field (t : t) (caller : string) (klass : string)
    (nat : string * string) =
  match List.assoc_opt klass !t with
  | Some kpool -> (
      match List.assoc_opt nat kpool.fields with
      | Some (_, entry) -> Ok entry
      | None -> failwith "invalid nat into loaded class")
  | None ->
      let ckd_cls =
        Jparser.parse_class (klass ^ ".class") |> Jparser.cook_class
      in
      t := (klass, ckd_cls) :: !t;
      let r =
        match List.assoc_opt ("<clinit>", "()V") ckd_cls.meths with
        | Some (LocalMeth meth) -> Error (ckd_cls, meth)
        | Some NativeMeth -> failwith "<clinit> shouldn't be native"
        | None -> get_field t caller klass nat
      in
      r

let rec get_method (t : t) (caller : string) (klass : string)
    (nat : string * string) =
  match List.assoc_opt klass !t with
  | Some kpool -> (
      match List.assoc_opt nat kpool.meths with
      | Some meth -> Ok meth
      | None -> failwith "invalid nat into loaded class")
  | None ->
      let ckd_cls =
        Jparser.parse_class (klass ^ ".class") |> Jparser.cook_class
      in
      t := (klass, ckd_cls) :: !t;
      let r =
        match List.assoc_opt ("<clinit>", "()V") ckd_cls.meths with
        | Some (LocalMeth meth) -> Error (ckd_cls, meth)
        | Some NativeMeth -> failwith "<clinit> shouldn't be native"
        | None -> get_method t caller klass nat
      in
      r

let show (t : t) =
  List.map
    (fun (kname, klass) -> kname ^ "\n" ^ Jparser.show_ckd_class klass)
    !t
  |> String.concat "\n"
