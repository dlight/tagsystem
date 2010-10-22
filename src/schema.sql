drop table if exists set_file, file, set;
drop type if exists status;

create table file
       (id              serial8 primary key,
        md5             varchar(32) not null,
        mime            text not null,
        size            int8 not null,
        path            text not null unique,

        image           bool not null default false,

        -- access time isn't necessarily updated..
        insert_time     timestamp not null default CURRENT_TIMESTAMP,
        access_time     timestamp not null default CURRENT_TIMESTAMP,
        update_time     timestamp not null default CURRENT_TIMESTAMP,

        dir_atime       timestamp,
        dir_ctime       timestamp,
        dir_mtime       timestamp,

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

        -- used to sort by 'most liked'
        score           int8 not null default 0,

        -- at each access, increase it (but not necesarily)
        access_count    int8 not null default 0,

        -- to be used on comparation with "return the 10 most recent"
        -- to take in account the historic unix timestamps
        sorting_time    timestamp not null default CURRENT_TIMESTAMP,

        insert_time     timestamp not null default CURRENT_TIMESTAMP,
        access_time     timestamp not null default CURRENT_TIMESTAMP,
        update_time     timestamp not null default CURRENT_TIMESTAMP,

        -- for use when adding from legacy directories (dating back to 2006)
        dir_atime       timestamp,
        dir_ctime       timestamp,
        dir_mtime       timestamp);

create table set_file
       (set_id   int8 references set,
        file_id  int8 not null references file,

        pos      int8 not null,

        filename text,
        url      text,

        primary key (set_id, pos));