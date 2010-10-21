open Dir
open Db
open Printf

let add_file db set_id file =
  (try file#link with e ->
     Printf.printf "%s %s\n" file#prev_path file#path;
     raise e);
  insert_file_rel db set_id file

let add db dir fs =
  let id = insert_set db dir in
  let l = of_dir id fs dir in
    mkdir_l l;
    List.iter (add_file db id) l

let add_dir db dir =
  match files dir with
      [||] -> raise (Failure "empty directory")
    | fs -> add db dir fs

let arg = match Sys.argv with
    [|a|] -> None
  | r -> Some r.(1)

let handle d =
  let db = connect() in
    add_dir db d

let _ = match arg with
    None -> print_endline "Rs"
  | Some a -> handle a
