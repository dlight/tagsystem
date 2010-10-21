drop table if exists set_file, file, set;
drop type if exists status;

create table file
       (id       serial8 primary key,
        md5      varchar(32) not null,
        mime     text not null,
        size     int8 not null,
        path            text not null unique,
        insert_time     timestamp not null default CURRENT_TIMESTAMP,
        image           bool not null default false,

        unique (md5, mime, size));

-- create type .. enum ..

-- principal true, user added false -> union? (or virtual?)
-- principal true, user added true  -> regular (or essay?)
-- principal false, user added true -> subset?

create table set
       (id          serial8 primary key,

        is_open      bool not null default true,
        principal    bool not null default false, -- principal and user_added can't be
        user_added   bool not null default true,  -- both false! (i.e. actually tri-state..)

        dir         text unique,
        url         text,
        insert_time timestamp not null default CURRENT_TIMESTAMP);

create table set_file
       (set_id   int8 references set,
        file_id  int8 not null references file,

        pos      int8 not null,

        filename text,
        url      text,

        primary key (set_id, pos));