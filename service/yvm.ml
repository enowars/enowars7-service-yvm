type primType =
  | Boolean of int
  | Byte of int
  | Short of int
  | Int of int32
  | Long of int64
  | Char of char
  | Float of float
  | Double of float
  | Reference
  | ReturnAddress

type constant =
  | C_Utf8 of string
  | C_Integer
  | C_Float
  | C_Long
  | C_Double
  | C_Class of { name_index : int }
  | C_String
  | C_Fieldref of { class_index : int; name_and_type_index : int }
  | C_Methodref of { class_index : int; name_and_type_index : int }
  | C_InterfaceMethodref of { class_index : int; name_and_type_index : int }
  | C_NameAndType of { name_index : int; descriptor_index : int }
  | C_MethodHandle
  | C_MethodType
  | C_Dynamic
  | C_InvokeDynamic
  | C_Module
  | C_Package
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
  name_index : int;
  descriptor_index : int;
  attributes : attribute_info array;
}
[@@deriving show]

type frame = { locals : primType list; operand_stack : primType list }
type foo = { pc : int; stack : frame list }

type jclass = {
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
  (*
    | 3 -> C_Integer
    | 4 -> C_Float
    | 5 -> C_Long
    | 6 -> C_Double
    | 8 -> C_String
        *)
  | 7 -> C_Class { name_index = input_u2 ic }
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
  (*
    | 15 -> C_MethodHandle
    | 16 -> C_MethodType
    | 17 -> C_Dynamic
    | 18 -> C_InvokeDynamic
    | 19 -> C_Module
    | 20 -> C_Package
        *)
  | _ -> failwith "unexpected Constant Kind Tag"

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
    constant_pool.(i) <- parse_cp_info ic
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
        name_index = -1;
        descriptor_index = -1;
        attributes = [||];
      }
  in

  for i = 0 to methods_count - 1 do
    let access_flags = input_u2 ic in
    let name_index = input_u2 ic in
    let descriptor_index = input_u2 ic in
    let attributes_count = input_u2 ic in
    let attributes =
      Array.make attributes_count { attribute_name_index = -1; info = "" }
    in
    for a = 0 to attributes_count - 1 do
      attributes.(a) <- parse_attribute_info ic
    done;
    methods.(i) <- { access_flags; name_index; descriptor_index; attributes }
  done;

  let attributes_count = input_u2 ic in
  let attributes =
    Array.make attributes_count { attribute_name_index = -1; info = "" }
  in
  for a = 0 to attributes_count - 1 do
    attributes.(a) <- parse_attribute_info ic
  done;

  show_jclass
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
  |> print_endline;
  Array.iteri
    (fun i el ->
      print_int i;
      print_char ' ';
      show_constant el |> print_endline)
    constant_pool;

  assert (In_channel.pos ic = In_channel.length ic);

  print_endline ""

let () = In_channel.with_open_bin "Foo.class" read_class
