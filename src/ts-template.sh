#!/bin/bash

dir_autoset=__ROOT__ # substituido pelo omake

cd "$dir_autoset"

c="$1"
shift

case $c in
    add) ./bin/ts-add "$@";;
    createdb) ./tools/createdb-simpler;;
    interface) ./tools/interface "$@";;
    *) cat "$0";;
esac
