open CalendarLib
open Printf
open Dir
open Dir.File

let read_id = function
    [] -> raise (Failure "qqq no id? (inserting file/set)")
  | id::_ -> id

let read_first = function
    [] -> None
  | a::_ -> Some a

let thumbnail_sizes db =
  PGSQL(db) "select width, height from thumbnail_size"

let insert_bag db dir =
  let min, now, a, m, c = Stat.min_now_file dir in
  let l = PGSQL(db) "insert into bag (dir,
    sorting_time, insert_time, access_time, update_time,
    dir_atime, dir_ctime, dir_mtime)

                    values ($dir, $min, $now, $now, $now, $a, $m, $c)
                    returning bag_id" in
    read_id l

let select_file_param db file =
  let { md5; mime; size } = file in
  let l = PGSQL(db) "select file_id from file
                      where md5 = $md5 and
                            mime = $mime and
                            file_size = $size" in
    read_first l

let select_and_do db file f =
  match select_file_param db file with
      None -> f file; None
    | Some a -> Some a

let insert_bag_file db file_id file =
  let { bag_id; pos; prev_name } = file in
  PGSQL(db) "insert into bag_file (bag_id, pos, file_id, file_name)
                    values ($bag_id, $pos, $file_id, $prev_name)"
let close_bag db bag_id =
  PGSQL(db) "update bag set is_open = false where bag_id = $bag_id"

let insert_image db file_id (width, height, quality) =
  PGSQL(db) "insert into image (file_id, width, height, quality) values
               ($file_id, $width, $height, $quality)"

let insert_just_file db file =
  let { md5; mime; magic;
        size; path; image } = file in

  let _, now, a, m, c = Stat.min_now_file path in

  let l = PGSQL(db)
    "insert into file
       (md5, mime, magic, file_size, repo_path,
        file_insert_time, file_access_time,
        file_update_time, file_atime,
        file_ctime, file_mtime)
     values
       ($md5, $mime, $magic, $size, $path,
        $now, $now, $now, $a, $c, $m)
     returning file_id" in
    read_id l

let insert_file db file =
  let file_id = insert_just_file db file in

    match file.image with
        Some data -> insert_image db file_id data; file_id
      | None -> file_id

let just_thumb db file_id parent_id w h =
  PGSQL(db) "insert into thumbnail
              (file_id, parent_id, max_width, max_height)
             values
              ($file_id, $parent_id, $w, $h)"

let just_add_file db file f =
  match select_and_do db file f with
      Some a -> a
    | None -> insert_file db file

let connect () =
  PGOCaml.connect ()
