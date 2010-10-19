(** Ahm *)

let insert_file db path =
  PGSQL(db) "insert into file (path) values ($path) returning id"

let insert_set db =
  PGSQL(db) "insert into set default values returning id"

let insert_set_file db set_id name_id pos =
  PGSQL(db) "insert into set_file (set_id, file_id, pos)
                    values ($set_id, $name_id, $pos)"

let get_set_file db =
  PGSQL(db) "select set.id, set_file.pos, file.id, file.path
                    from set, file, set_file
                    where (set_file.set_id = set.id and
                           set_file.file_id = file.id)"

let begin_new_set db dir url =
  PGSQL(db) "insert into new_set (dir, url)
                   values ($dir, $url) returning id"
