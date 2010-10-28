drop table if exists bag_file, thumbnails, file, bag;

create table file
       (file_id         serial8 primary key,
        md5             varchar(32) not null,
        mime            text not null,
        magic           text not null,
        file_size       int8 not null,
        repo_path       text not null unique,

        -- if image is true, those fields can't be null...
        image           bool not null default false,
        width           int,
        height          int,
        quality         int,

        -- access time isn't necessarily updated..
        file_insert_time     timestamp not null default current_timestamp,
        file_access_time     timestamp not null default current_timestamp,
        file_update_time     timestamp not null default current_timestamp,

        file_atime       timestamp,
        file_ctime       timestamp,
        file_mtime       timestamp,

        unique (md5, mime, file_size));

create table thumbnails
       (file_id         serial8 references file on delete cascade,
        max_width       int not null,
        max_height      int not null,

        actual_width    int not null,
        actual_height   int not null,
        quality         int not null,
        scaled          bool,
        repo_path       text not null unique,

        primary key (file_id, max_height, max_width));

create table bag
       (bag_id       serial8 primary key,

        is_open      bool not null default true,
        principal    bool not null default false, -- principal and user_added can't be
        user_added   bool not null default true,  -- both false! (i.e. actually tri-state..)

        dir         text unique,
        bag_url     text,

        -- used to sort by 'most liked'
        score           int8 not null default 0,

        -- at each access, increase it (but not necesarily)
        access_count    int8 not null default 0,

        -- to be used on comparation with "return the 10 most recent"
        -- to take in account the historic unix timestamps
        sorting_time    timestamp not null default current_timestamp,

        insert_time     timestamp not null default current_timestamp,
        access_time     timestamp not null default current_timestamp,
        update_time     timestamp not null default current_timestamp,

        -- for use when adding from legacy directories (dating back to 2006)
        dir_atime       timestamp,
        dir_ctime       timestamp,
        dir_mtime       timestamp);

create table bag_file
       (bag_id    int8 references bag on delete cascade,
        file_id   int8 not null references file on delete cascade,

        pos       int8 not null,

        file_name text,
        file_url  text,

        primary key (bag_id, pos));