type pool_entry = Method of Jparser.meth | Int of int
type klass = Jparser.ckd_class
type t = (string * klass) list ref

let not_found what nat klass =
  let name, typ = nat in
  "could not find " ^ what ^ " " ^ name ^ " with type " ^ typ ^ " in class "
  ^ klass
  |> Exc.fail_usage

let rec get_field (t : t) (caller : string) (klass : string)
    (nat : string * string) =
  match List.assoc_opt klass !t with
  | Some kpool -> (
      match List.assoc_opt nat kpool.fields with
      | Some (_, entry) -> Ok entry
      | None -> not_found "field" nat klass)
  | None ->
      let ckd_cls =
        Jparser.parse_class (klass ^ ".class") |> Jparser.cook_class
      in
      t := (klass, ckd_cls) :: !t;
      let r =
        match List.assoc_opt ("<clinit>", "()V") ckd_cls.meths with
        | Some (_, LocalMeth meth) -> Error (ckd_cls, meth)
        | Some (_, NativeMeth) -> failwith "<clinit> shouldn't be native"
        | None -> get_field t caller klass nat
      in
      r

let rec get_method (t : t) (caller : string) (klass : string)
    (nat : string * string) =
  match List.assoc_opt klass !t with
  | Some kpool -> (
      match List.assoc_opt nat kpool.meths with
      | Some (Some ACC_PRIVATE, meth) ->
          if caller = klass then Ok meth else Exc.fail_usage "illegal access"
      | Some (_, meth) -> Ok meth
      | None -> not_found "field" nat klass)
  | None ->
      let ckd_cls =
        Jparser.parse_class (klass ^ ".class") |> Jparser.cook_class
      in
      t := (klass, ckd_cls) :: !t;
      let r =
        match List.assoc_opt ("<clinit>", "()V") ckd_cls.meths with
        | Some (_, LocalMeth meth) -> Error (ckd_cls, meth)
        | Some (_, NativeMeth) -> failwith "<clinit> shouldn't be native"
        | None -> get_method t caller klass nat
      in
      r
