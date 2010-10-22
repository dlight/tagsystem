open Dir
open Db
open Printf

module U = ExtUnix.Specific

let link_file db file =
  match select_file_param db file#md5 file#mime file#size with
      None -> (try file#link with e ->
                 Printf.printf "Aiai link: %s -> %s\n\n" file#prev_path file#path;
                 raise e); None
    | Some a -> Some a

let add_file db set_id file =
  let file_id' = link_file db file in
  insert_file_rel db file_id' set_id file

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
  | Some a -> handle (U.realpath a)
