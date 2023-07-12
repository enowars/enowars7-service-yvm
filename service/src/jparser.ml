type primType =
  | P_Int of int32
  | P_Char of char
  | P_Reference of primType array option
  | P_Dummy
[@@deriving show]

type constant =
  | C_Utf8 of string
  | C_Integer of int32
  | C_Float of float
  | C_Long of int
  | C_Double of float
  | C_Class of { name_index : int }
  | C_String of { string_index : int }
  | C_Fieldref of { class_index : int; name_and_type_index : int }
  | C_Methodref of { class_index : int; name_and_type_index : int }
  | C_InterfaceMethodref of { class_index : int; name_and_type_index : int }
  | C_NameAndType of { name_index : int; descriptor_index : int }
  | C_MethodHandle of { reference_kind : int; reference_index : int }
  | C_MethodType of { descriptor_index : int }
  | C_Dynamic of {
      bootstrap_method_attr_index : int;
      name_and_type_index : int;
    }
  | C_InvokeDynamic of {
      bootstrap_method_attr_index : int;
      name_and_type_index : int;
    }
  | C_Module
  | C_Package
[@@deriving show]

type ckd_constant =
  | CKD_Dummy
  | CKD_Method of { klass : string; name_and_type : string * string }
  | CKD_Field of { klass : string; name_and_type : string * string }
[@@deriving show]

type access_flag = ACC_PUBLIC | ACC_PRIVATE | ACC_PROTECTED [@@deriving show]
type access_flag_1 = ACC_FINAL | ACC_VOLATILE [@@deriving show]

type attribute_info = { attribute_name_index : int; info : string }
[@@deriving show]

type attribute =
  | AT_Code of {
      attribute_name_index : int;
      max_stack : int;
      max_locals : int;
      code : string;
      attribute_info : attribute_info array;
    }
    (* TODO exception table *)
[@@deriving show]

type field_info = {
  access_flags : access_flag option;
  access_flag_1 : access_flag_1 option;
  is_static : bool;
  is_transient : bool;
  is_synthetic : bool;
  is_enum : bool;
  name_index : int;
  descriptor_index : int;
  attributes : attribute_info array;
}
[@@deriving show]

type method_info = {
  access_flags : int;
  is_native : bool;
  name_index : int;
  descriptor_index : int;
  attributes : attribute_info array;
}
[@@deriving show]

type raw_class = {
  version : int * int;
  constant_pool : constant array;
  access_flags : int;
  this_class : int;
  super_class : int;
  interfaces : int array;
  fields : field_info array;
  methods : method_info array;
  attributes : attribute_info array;
}
[@@deriving show]

type exc_table_entry = {
  start_pc : int;
  end_pc : int;
  handler_pc : int;
  catch_type : int;
}
[@@deriving show]

type lmeth = {
  max_stack : int;
  max_locals : int;
  code : string;
  exc_table : exc_table_entry array;
}
[@@deriving show]

type meth = NativeMeth | LocalMeth of lmeth [@@deriving show]

type ckd_class = {
  name : string;
  super : string;
  constant_pool : constant array;
  ckd_cp : ckd_constant array;
  meths : ((string * string) * meth) list;
  fields : ((string * string) * (access_flag option * primType ref)) list;
}
[@@deriving show]

(* TODO kaputt bei signed input?! *)
let input_u2 ic =
  let b1 = input_byte ic lsl 8 in
  let b2 = input_byte ic in
  b1 lor b2

let input_u4 ic =
  let u21 = input_u2 ic lsl 16 in
  let u22 = input_u2 ic in
  u21 lor u22

let input_u8 ic =
  let u41 = input_u4 ic lsl 32 in
  let u42 = input_u4 ic in
  u41 lor u42

let parse_cp_info ic =
  let kind = input_byte ic in
  match kind with
  | 1 ->
      let length = input_u2 ic in
      C_Utf8 (really_input_string ic length)
  | 3 -> C_Integer (input_u4 ic |> Int32.of_int)
  | 4 -> C_Float (input_u4 ic |> Int32.of_int |> Int32.float_of_bits)
  | 5 -> C_Long (input_u8 ic)
  | 6 -> C_Double (input_u8 ic |> Int64.of_int |> Int64.float_of_bits)
  | 7 -> C_Class { name_index = input_u2 ic }
  | 8 -> C_String { string_index = input_u2 ic }
  | 9 ->
      let class_index = input_u2 ic in
      let name_and_type_index = input_u2 ic in
      C_Fieldref { class_index; name_and_type_index }
  | 10 ->
      let class_index = input_u2 ic in
      let name_and_type_index = input_u2 ic in
      C_Methodref { class_index; name_and_type_index }
  | 11 ->
      let class_index = input_u2 ic in
      let name_and_type_index = input_u2 ic in
      C_InterfaceMethodref { class_index; name_and_type_index }
  | 12 ->
      let name_index = input_u2 ic in
      let descriptor_index = input_u2 ic in
      C_NameAndType { name_index; descriptor_index }
  | 15 ->
      let reference_kind = input_byte ic in
      let reference_index = input_u2 ic in
      C_MethodHandle { reference_kind; reference_index }
  | 16 ->
      let descriptor_index = input_u2 ic in
      C_MethodType { descriptor_index }
  | 17 ->
      let bootstrap_method_attr_index = input_u2 ic in
      let name_and_type_index = input_u2 ic in
      C_Dynamic { bootstrap_method_attr_index; name_and_type_index }
  | 18 ->
      let bootstrap_method_attr_index = input_u2 ic in
      let name_and_type_index = input_u2 ic in
      C_InvokeDynamic { bootstrap_method_attr_index; name_and_type_index }
  (*
    | 19 -> C_Module
    | 20 -> C_Package
        *)
  | tag -> tag |> Printf.sprintf "unexpected Constant Kind Tag: %d" |> failwith

let parse_attribute_info ic =
  let attribute_name_index = input_u2 ic in
  let length = input_u4 ic in
  { attribute_name_index; info = really_input_string ic length }

let parse_field_info ic =
  let access_flags_int = input_u2 ic in
  let access_flags =
    match access_flags_int land 0b111 with
    | 0 -> None
    | 1 -> Some ACC_PUBLIC
    | 2 -> Some ACC_PRIVATE
    | 4 -> Some ACC_PROTECTED
    | _ -> failwith "unexpected acces type"
  in
  let is_static = access_flags_int land 0x0008 = 1 in
  let access_flag_1 =
    match access_flags_int land 0b1110000 with
    | 0 -> None
    | 0x0010 -> Some ACC_FINAL
    | 0x0040 -> Some ACC_VOLATILE
    | _ -> failwith "unexpected acces type"
  in
  let is_transient = access_flags_int land 0x0080 = 1 in
  let is_synthetic = access_flags_int land 0x1000 = 1 in
  let is_enum = access_flags_int land 0x4000 = 1 in
  let name_index = input_u2 ic in
  let descriptor_index = input_u2 ic in
  let attributes_count = input_u2 ic in
  let attributes =
    Array.make attributes_count { attribute_name_index = -1; info = "" }
  in
  for a = 0 to attributes_count - 1 do
    attributes.(a) <- parse_attribute_info ic
  done;
  {
    access_flags;
    access_flag_1;
    is_static;
    is_transient;
    is_synthetic;
    is_enum;
    name_index;
    descriptor_index;
    attributes;
  }

let read_class ic =
  assert (input_u4 ic = 0xcafebabe);
  let minor = input_u2 ic in
  let major = input_u2 ic in
  let constant_pool_count = input_u2 ic in
  let constant_pool = Array.make constant_pool_count (C_Utf8 "fill") in
  for i = 1 to constant_pool_count - 1 do
    match constant_pool.(i - 1) with
    (* skip since Double and Long take two slots *)
    | C_Double _ -> ()
    | C_Long _ -> ()
    | _ -> constant_pool.(i) <- parse_cp_info ic
  done;
  let access_flags = input_u2 ic in
  let this_class = input_u2 ic in
  let super_class = input_u2 ic in
  let interfaces_count = input_u2 ic in
  let interfaces = Array.make interfaces_count 0 in
  for i = 0 to interfaces_count - 1 do
    interfaces.(i) <- input_u2 ic
  done;

  let fields_count = input_u2 ic in
  let fields =
    Array.make fields_count
      {
        access_flags = None;
        access_flag_1 = None;
        is_static = false;
        is_transient = false;
        is_synthetic = false;
        is_enum = false;
        name_index = -1;
        descriptor_index = -1;
        attributes = [||];
      }
  in
  for i = 0 to fields_count - 1 do
    fields.(i) <- parse_field_info ic
  done;

  let methods_count = input_u2 ic in
  let methods =
    Array.make methods_count
      {
        access_flags = -1;
        is_native = false;
        name_index = -1;
        descriptor_index = -1;
        attributes = [||];
      }
  in

  for i = 0 to methods_count - 1 do
    let access_flags = input_u2 ic in
    let is_native = access_flags land 0x0100 != 0 in
    let name_index = input_u2 ic in
    let descriptor_index = input_u2 ic in
    let attributes_count = input_u2 ic in
    let attributes =
      Array.make attributes_count { attribute_name_index = -1; info = "" }
    in
    for a = 0 to attributes_count - 1 do
      attributes.(a) <- parse_attribute_info ic
    done;
    methods.(i) <-
      { access_flags; is_native; name_index; descriptor_index; attributes }
  done;

  let attributes_count = input_u2 ic in
  let attributes =
    Array.make attributes_count { attribute_name_index = -1; info = "" }
  in
  for a = 0 to attributes_count - 1 do
    attributes.(a) <- parse_attribute_info ic
  done;

  assert (In_channel.pos ic = In_channel.length ic);
  {
    version = (major, minor);
    constant_pool;
    access_flags;
    this_class;
    super_class;
    interfaces;
    fields;
    methods;
    attributes;
  }

let parse_class path = In_channel.with_open_bin path read_class

let rslv_name cp idx =
  match cp.(idx) with C_Utf8 str -> str | _ -> failwith "expected string"

let rslv_class cp idx =
  match cp.(idx) with
  | C_Class c -> rslv_name cp c.name_index
  | _ -> failwith "expected class"

let rslv_name_and_type cp ntidx =
  match cp.(ntidx) with
  | C_NameAndType { name_index; descriptor_index } ->
      (rslv_name cp name_index, rslv_name cp descriptor_index)
  | _ -> failwith "expected name_and_type"

let cook_cp_entry (cp : constant array) (cp_entry : constant) =
  match cp_entry with
  | C_Methodref { class_index; name_and_type_index } ->
      let klass = rslv_class cp class_index in
      let name_and_type = rslv_name_and_type cp name_and_type_index in
      CKD_Method { klass; name_and_type }
  | C_Fieldref { class_index; name_and_type_index } ->
      let klass = rslv_class cp class_index in
      let name_and_type = rslv_name_and_type cp name_and_type_index in
      CKD_Field { klass; name_and_type }
  | _ -> CKD_Dummy

let cook_field cp (raw_field : field_info) =
  let name = rslv_name cp raw_field.name_index in
  let dscr = rslv_name cp raw_field.descriptor_index in
  let acc = raw_field.access_flags in
  match dscr with
  | "I" -> ((name, dscr), (acc, ref (P_Int 1337l)))
  | s when String.get s 0 = '[' -> ((name, dscr), (acc, ref (P_Reference None)))
  | s -> "unsupported field type " ^ s |> failwith

let cook_meth cp raw_meth =
  let name = rslv_name cp raw_meth.name_index in
  let dscr = rslv_name cp raw_meth.descriptor_index in
  if raw_meth.is_native then ((name, dscr), NativeMeth)
  else
    let code_attr = raw_meth.attributes.(0) in
    assert (rslv_name cp code_attr.attribute_name_index = "Code");
    let code_str = code_attr.info in
    let max_stack = String.get_uint16_be code_str 0 in
    let max_locals = String.get_uint16_be code_str 2 in
    let code_len = String.get_int32_be code_str 4 |> Int32.to_int in
    ( (name, dscr),
      LocalMeth
        {
          max_stack;
          max_locals;
          code = String.sub code_str 8 code_len;
          exc_table = [||];
        } )

let cook_class (raw_class : raw_class) =
  let cp = raw_class.constant_pool in
  let name = rslv_class cp raw_class.this_class in
  let super = rslv_class cp raw_class.super_class in
  let ckd_cp = Array.map (cook_cp_entry cp) cp in
  let meths = raw_class.methods |> Array.map (cook_meth cp) |> Array.to_list in
  let fields = raw_class.fields |> Array.map (cook_field cp) |> Array.to_list in
  { name; super; constant_pool = cp; ckd_cp; meths; fields }
