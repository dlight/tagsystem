open Batteries
open Dir
open Dir.File
open Db
open Printf

module O = Opt

module U = ExtUnix.Specific

let link_file file =
    try link_f file with e ->
      Printf.fprintf stderr "Aiai link: %s -> %s\n\n" file.prev_path file.path;
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

let do_it db sizes d =
  try
    PGOCaml.begin_work db;
    mkdir_tmp_dir();
    add_dir db sizes d;
    PGOCaml.commit db
  with
        e -> PGOCaml.rollback db;
          fprintf stderr "Erro capturado: ";
          (Printexc.print stderr e);
          fprintf stderr "\n%!"

let handle db sizes d =
  O.p O.Alot "Adding %s ..\n" d;
  do_it db sizes d;
  O.p O.Abit "%s added.\n" d

let _ =
  let db = connect() in
  let sizes = thumbnail_sizes db in
  O.parse();

  List.iter (handle db sizes) !O.arg
