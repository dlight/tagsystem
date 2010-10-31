open Dir
open Dir.File
open Db
open Printf

module U = ExtUnix.Specific

let link_file db file =
  match select_file_param db file with
      None -> (try link_f file with e ->
                 Printf.printf "Aiai link: %s -> %s\n\n" file.prev_path file.path;
                 raise e); None
    | Some a -> Some a

let add_file db file =
  let file_id' = link_file db file in
  insert_file_rel db file_id' file

let add db dir fs =
  let bag_id = insert_bag db dir in
  let l = of_dir bag_id fs dir in
    mkdir_l l;
    List.iter (add_file db) l;
    close_bag db bag_id

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
