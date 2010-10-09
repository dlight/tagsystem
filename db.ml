let create_db db =
  PGSQL(db) "execute"
    "drop table if exists set_file, file, set";
  PGSQL(db) "execute"
    "create table file
       (id       serial primary key,
        path     text not null unique)";
  PGSQL(db) "execute"
    "create table set
       (id       serial primary key)";
  PGSQL(db) "execute"
    "create table set_file
       (set_id   int references set,
        file_id  int references file,
        pos      int not null,

        primary key (set_id, pos))"

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
