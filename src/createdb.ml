let create db =
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
