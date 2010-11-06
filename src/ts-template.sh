#!/bin/bash

# substituido pelo omake
dir_autoset=__ROOT__
# risos

files_dir="$HOME/files"

BIN="$dir_autoset/bin"
WEB="$dir_autoset/web"
TOOLS="$dir_autoset/tools"

c="$1"
shift

case "$c" in
    add-dir)
        for i in "$@"; do
            for j in "$i"/*; do
                echo
                $0 add "$j"
            done
        done;;
    clean) $0 rm; $0 createdb;;
    add) "$BIN"/ts-add "$@";;
    rm) rm -rf "$files_dir"/?*;;
    createdb) "$TOOLS"/createdb-simpler;;
    interface) "$TOOLS"/interface "$@";;
    web) "$TOOLS"/web;;
    *) cat "$0";;
esac
