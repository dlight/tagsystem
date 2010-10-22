open CalendarLib
open Printf
open Dir

let read_id = function
    [] -> raise (Failure "qqq no id? (inserting file/set)")
  | id::_ -> id

let read_first = function
    [] -> None
  | a::_ -> Some a

let insert_set db dir =
  let l = PGSQL(db) "insert into set (dir)
                    values ($dir) returning id" in
    read_id l

let select_file_param db md5 mime size =
  let l = PGSQL(db) "select id from file
                      where md5 = $md5 and
                            mime = $mime and
                            size = $size" in
    read_first l

let insert_file db md5 mime size path image =
  let l = PGSQL(db) "insert into file (md5, mime, size, path, image)
                    values ($md5, $mime, $size, $path, $image)
                    returning id" in
    read_id l

let insert_set_file db set_id pos file_id filename =
  PGSQL(db) "insert into set_file (set_id, pos, file_id, filename)
                    values ($set_id, $pos, $file_id, $filename)"

let get_set_file db =
  PGSQL(db) "select set.id, set_file.pos, file.id, file.path
                    from set, file, set_file
                    where (set_file.set_id = set.id and
                           set_file.file_id = file.id)"

let close_set db set_id =
  PGSQL(db) "update set set is_open = false where id = $set_id"

(* hard to manage? *)

let fid_if_exists db md5 mime size path image = function
    Some a -> a
  | None -> insert_file db md5 mime size path image

let unpack file =
  (file#md5, file#mime, file#size, file#path, file#image,
   file#pos, file#prev_name)

let insert_file_rel db file_id' set_id file =
  let md5, mime, size, path, image,
    pos, filename = unpack file in
    let file_id =
      fid_if_exists db md5 mime size path image file_id' in

      insert_set_file db set_id pos file_id filename

let connect () = PGOCaml.connect ()
