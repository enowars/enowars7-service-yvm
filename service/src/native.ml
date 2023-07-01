let to_str carr = carr |> Array.to_seq |> String.of_seq
let to_carr str = str |> String.to_seq |> Array.of_seq

let get_token () =
  let l = 20 in
  let arr = Array.make l 'a' in
  for i = 0 to l - 1 do
    let c = Random.int 26 |> ( + ) (Char.code 'a') |> Char.chr in
    arr.(i) <- c
  done;
  arr

let mkdir dir =
  let dir = to_str dir in
  try
    Sys.mkdir dir 0x755;
    true
  with Sys_error _ -> false

let ls dir =
  let dir = to_str dir in
  Sys.readdir dir |> Array.map to_carr

let error error = error |> to_str |> prerr_endline

let write file content =
  let file = to_str file in
  let content = to_str content in
  let flags = [ Open_wronly; Open_creat; Open_excl; Open_text ] in
  let put_content oc = output_string oc content in
  try
    Out_channel.with_open_gen flags 0o400 file put_content;
    true
  with Sys_error _ -> false

let read file =
  let file = to_str file in
  try
    let t = In_channel.with_open_text file In_channel.input_all in
    Some (to_carr t)
  with Sys_error _ -> None
