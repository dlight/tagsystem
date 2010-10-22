#!/bin/bash

dir_autoset=__ROOT__ # substituido pelo omake
files_dir="$HOME/files"

BIN="$dir_autoset/bin"
WEB="$dir_autoset/web"
TOOLS="$dir_autoset/tools"

c="$1"
shift

case "$c" in
    add) "$BIN"/ts-add "$@";;
    rm) rm -rf "$files_dir"/?*;;
    createdb) "$TOOLS"/createdb-simpler;;
    interface) "$TOOLS"/interface "$@";;
    web) "$WEB"/ts-web;;
    *) cat "$0";;
esac
