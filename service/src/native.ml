let ptchar_to_char = function
  | Jparser.P_Char c -> c
  | Jparser.P_Int i -> Char.chr (Int32.to_int i)
  | _ -> failwith "foo"

let to_str = function
  | Jparser.P_Reference (Some arr) ->
      arr |> Array.map ptchar_to_char |> Array.to_seq |> String.of_seq
  | _ -> failwith "foo"

let to_carr str = str |> String.to_seq |> Array.of_seq

let str_to_prt str =
  Jparser.P_Reference
    (Some
       (str |> String.to_seq |> Array.of_seq
       |> Array.map (fun c -> Jparser.P_Char c)))

let get_args () = Jparser.P_Reference (Some (Array.map str_to_prt Sys.argv))

let get_token () =
  let l = 20 in
  let arr = Array.make l (Jparser.P_Char 'a') in
  for i = 0 to l - 1 do
    let c = Random.int 26 |> ( + ) (Char.code 'a') |> Char.chr in
    arr.(i) <- P_Char c
  done;
  Jparser.P_Reference (Some arr)

let mkdir dir =
  let dir = to_str dir in
  try
    Sys.mkdir dir 0x755;
    Jparser.P_Int 1l
  with Sys_error _ -> Jparser.P_Int 0l

let ls dir =
  let dir = to_str dir in
  Jparser.P_Reference (Some (Sys.readdir dir |> Array.map str_to_prt))

let error error = error |> to_str |> prerr_endline

let write file content =
  let file = to_str file in
  let content = to_str content in
  let flags = [ Open_wronly; Open_creat; Open_excl; Open_text ] in
  let put_content oc = output_string oc content in
  try
    Out_channel.with_open_gen flags 0o400 file put_content;
    Jparser.P_Int 1l
  with Sys_error _ -> Jparser.P_Int 0l

let read file =
  let file = to_str file in
  try
    let t = In_channel.with_open_text file In_channel.input_all in
    str_to_prt t
  with Sys_error _ -> P_Reference None
