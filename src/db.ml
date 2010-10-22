open CalendarLib
open Printf
open Dir

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

let select_file_param db md5 mime size =
  let l = PGSQL(db) "select file_id from file
                      where md5 = $md5 and
                            mime = $mime and
                            file_size = $size" in
    read_first l

let insert_file db md5 mime magic size repo_path image =
  let _, now, a, m, c = Stat.min_now_file repo_path in

  let l = PGSQL(db) "insert into file (md5, mime, magic, file_size, repo_path, image,
    file_insert_time, file_access_time, file_update_time,
    file_atime, file_ctime, file_mtime)
                    values ($md5, $mime, $magic, $size, $repo_path, $image,
    $now, $now, $now, $a, $c, $m)
                    returning file_id" in
    read_id l

let insert_bag_file db bag_id pos file_id file_name =
  PGSQL(db) "insert into bag_file (bag_id, pos, file_id, file_name)
                    values ($bag_id, $pos, $file_id, $file_name)"
let close_bag db bag_id =
  PGSQL(db) "update bag set is_open = false where bag_id = $bag_id"

(* hard to manage? *)

let fid_if_exists db md5 mime magic size path image = function
    Some a -> a
  | None -> insert_file db md5 mime magic size path image

let unpack file =
  (file#md5, file#mime, file#magic, file#size, file#path, file#image,
   file#pos, file#prev_name)

let insert_file_rel db file_id' bag_id file =
  let md5, mime, magic, size, path, image,
    pos, file_name = unpack file in
    let file_id =
      fid_if_exists db md5 mime magic size path image file_id' in

      insert_bag_file db bag_id pos file_id file_name

let connect () = PGOCaml.connect ()
