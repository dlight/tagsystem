drop table if exists set_file, file, set, new_set, new_set_file;
drop type if exists status;
create type status as enum ('open', 'finished', 'added');

create table file
       (id       serial8 primary key,
        md5      varchar(32) not null,
        mime     text not null,
        size     int8 not null,
        path            text not null unique,
        insert_time     timestamp not null default CURRENT_TIMESTAMP,
        relevant        bool not null default false,

        unique (md5, mime, size));

create table set
       (id          serial8 primary key,
        dir         text,
        url         text,
        insert_time timestamp not null default CURRENT_TIMESTAMP);

create table set_file
       (set_id   int8 references set,
        file_id  int8 not null references file,
        filename text not null,
        pos      int8 not null,

        primary key (set_id, pos));


create table new_set
       (id         serial8 primary key,
        status     status not null default 'open',
        init_time  timestamp not null default CURRENT_TIMESTAMP,
        dir        text,
        url        text);

create table new_set_file
       (new_set_id   int8 references new_set,
        file_id      int8 references file,
        filename     text not null,
        pos          int8 not null);