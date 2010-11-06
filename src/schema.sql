drop table if exists thumbnail_type, config, bag_file, file, thumbnail, image, bag cascade;

create table thumbnail_type
       (width           int,
        height          int,
        primary key (width, height));

insert into thumbnail_type values (840, 630);
insert into thumbnail_type values (600, 450);

create table config
        -- def_width and def_height being null means hi-res is default
        -- (I could use the value "0" instead.. like 0x0 means hi-res)
       (def_width       int,
        def_height      int,

        foreign key (def_width, def_height)
        references thumbnail_type(width, height));

create unique index only_one_config on config ((1));

create table file
       (file_id         serial8 primary key,
        md5             varchar(32) not null,
        mime            text not null,
        magic           text not null,
        file_size       int8 not null,
        repo_path       text not null unique,

        -- access time isn't necessarily updated..
        file_insert_time     timestamp not null default current_timestamp,
        file_access_time     timestamp not null default current_timestamp,
        file_update_time     timestamp not null default current_timestamp,

        file_atime       timestamp,
        file_ctime       timestamp,
        file_mtime       timestamp,

        unique (md5, mime, file_size));

create table image
       (file_id        serial8 primary key references file on delete cascade,
        width           int not null,
        height          int not null,
        quality         int not null);

-- if file_id = parent_id, image was not scaled
-- it references image in order to prevent non-images to have thumbnails
create table thumbnail
        -- file_id references its own id
       (file_id         int8 not null primary key references file
                                      on delete cascade,
        image_id        int8 not null references image
                                      on delete cascade,
        parent_id       int8 not null references file,
        max_width       int not null,
        max_height      int not null,

        unique (parent_id, max_height, max_width),

        foreign key (max_width, max_height)
        references thumbnail_type(width, height));

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
       (bag_id    int8 not null references bag on delete cascade,
        file_id   int8 not null references file on delete cascade,

        pos       int8 not null,

        file_name text,
        file_url  text,

        primary key (bag_id, pos));