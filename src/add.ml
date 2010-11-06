open Dir
open Dir.File
open Db
open Printf

module U = ExtUnix.Specific

let link_file file =
    try link_f file with e ->
      Printf.printf "Aiai link: %s -> %s\n\n" file.prev_path file.path;
      raise e

let thumb_aux db parent_id file max_w max_h =
  let file_id = just_add_file db file mv_f in
    just_thumb db file_id parent_id max_w max_h

let add_file db sizes file =
  let file_id = just_add_file db file link_file in
    insert_bag_file db file_id file;
    add_thumbnails (thumb_aux db file_id) sizes file

let add db sizes dir fs =
  let bag_id = insert_bag db dir in
  let l = of_dir bag_id fs dir in
    mkdir_l l;
    List.iter (add_file db sizes) l;
    close_bag db bag_id

let add_dir db sizes dir =
  match files dir with
      [||] -> raise (Failure "empty directory")
    | fs -> add db sizes dir fs

let arg = match Sys.argv with
    [|a|] -> None
  | r -> Some r.(1)

let handle d =
  let db = connect() in
  let sizes = thumbnail_sizes db in
    printf "Adding %s ..\n" d;
    mkdir_tmp_dir();
    add_dir db sizes d;
    printf "%s added.\n" d

let _ = match arg with
    None -> print_endline "Rs"
  | Some a -> handle (U.realpath a)
