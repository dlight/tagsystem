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

let insert_bag_file db file_id file =
  let { bag_id; pos; prev_name } = file in
  PGSQL(db) "insert into bag_file (bag_id, pos, file_id, file_name)
                    values ($bag_id, $pos, $file_id, $prev_name)"
let close_bag db bag_id =
  PGSQL(db) "update bag set is_open = false where bag_id = $bag_id"

let insert_file db file  =
  let { md5; mime; magic; size; path; image; width; height; quality } = file in
  let _, now, a, m, c = Stat.min_now_file path in

  let l = PGSQL(db) "insert into file (md5, mime, magic, file_size, repo_path, image,
    width, height, quality,
    file_insert_time, file_access_time, file_update_time,
    file_atime, file_ctime, file_mtime)
                    values ($md5, $mime, $magic, $size, $path, $image,
    $?width, $?height, $?quality,
    $now, $now, $now, $a, $c, $m)
                    returning file_id" in
    read_id l

let fid_if_exists db file = function
    Some a -> a
  | None -> insert_file db file

let insert_file_rel db file_id' file =
    let file_id = fid_if_exists db file file_id' in
      insert_bag_file db file_id file

let connect () = PGOCaml.connect ()
