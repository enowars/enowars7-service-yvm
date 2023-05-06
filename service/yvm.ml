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
  | C_Utf8
  | C_Integer
  | C_Float
  | C_Long
  | C_Double
  | C_Class
  | C_String
  | C_Fieldref
  | C_Methodref of { class_index : int; name_and_type_index : int }
  | C_InterfaceMethodref
  | C_NameAndType
  | C_MethodHandle
  | C_MethodType
  | C_Dynamic
  | C_InvokeDynamic
  | C_Module
  | C_Package

type frame = { locals : primType list; operand_stack : primType list }
type foo = { pc : int; stack : frame list }

type jclass = { version : int * int; constant_pool : constant array }

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

let read_class ic =
  input_char ic |> Char.code |> Printf.printf "%x";
  input_char ic |> Char.code |> Printf.printf "%x";
  input_char ic |> Char.code |> Printf.printf "%x";
  input_char ic |> Char.code |> Printf.printf "%x";
  print_endline "";
  let minor = input_u2 ic in
  let major = input_u2 ic in
  Printf.printf "v%d.%d\n" major minor;
  let constant_pool_count = input_u2 ic in
  print_int constant_pool_count;
  print_endline "";
  let kind = input_byte ic in
  print_int kind;
  print_endline "";
  let constant_pool = Array.make constant_pool_count C_Utf8 in
  for i = 0 to constant_pool_count - 1 do
    let c =
      match kind with
      | 1 -> C_Utf8
      | 3 -> C_Integer
      | 4 -> C_Float
      | 5 -> C_Long
      | 6 -> C_Double
      | 7 -> C_Class
      | 8 -> C_String
      | 9 -> C_Fieldref
      | 10 ->
          C_Methodref
            { class_index = input_u2 ic; name_and_type_index = input_u2 ic }
      | 11 -> C_InterfaceMethodref
      | 12 -> C_NameAndType
      | 15 -> C_MethodHandle
      | 16 -> C_MethodType
      | 17 -> C_Dynamic
      | 18 -> C_InvokeDynamic
      | 19 -> C_Module
      | 20 -> C_Package
      | _ -> raise (Failure "unexpected Constant Kind Tag")
    in
    constant_pool.(i) <- c
  done;
  (*
  show_jclass { version = (1, 1); constant_pool = constant_pool } |> print_endline;
     *)
  print_endline ""

let () = In_channel.with_open_bin "Foo.class" read_class
