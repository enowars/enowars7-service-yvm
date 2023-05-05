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

type frame = { locals : primType list; operand_stack : primType list }
type foo = { pc : int; stack : frame list }
