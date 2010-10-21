#!/bin/bash

dir_autoset=__ROOT__ # substituido pelo omake
files_dir="$HOME/files"

cd "$dir_autoset"

c="$1"
shift

case "$c" in
    add) ./bin/ts-add "$@";;
    rm) rm -r "$files_dir";;
    createdb) ./tools/createdb-simpler;;
    interface) ./tools/interface "$@";;
    *) cat "$0";;
esac
