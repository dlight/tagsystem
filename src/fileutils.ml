(* Resolvi usar FileUtil por enquanto *)

open Filename
open List
open Sys
let mkdir = Unix.mkdir

type ts = Isdir | Nodir | Nofile

let classify s =
  if file_exists s then
    if is_directory s
    then Isdir
    else Nodir
  else
    Nofile

let list s =
  let rec list' acc = function
      "." | "/" | ".." -> acc
    | dir -> list' (dir :: acc) (dirname dir) in

  rev (list' [] s)

