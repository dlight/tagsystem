drop table if exists set_file, file, set;

create table file
       (id       serial primary key,
        path     text not null unique);

create table set
       (id       serial primary key);

create table set_file
       (set_id   int references set,
        file_id  int references file,
        pos      int not null,

        primary key (set_id, pos));