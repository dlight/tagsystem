open Filename
open File
open Printf
open Sys

(* I may remove this dependency *)
let mkdir dir = FileUtil.mkdir ~parent:true dir
let mv = FileUtil.mv

type ('a, 'b) either = Left of 'a | Right of 'b

let cookie = Magic.make ~flags:[Magic.Mime] []

let dir = concat (getenv "HOME") "files"

let ext_rel_of_mime = function
    "image/jpeg" -> "jpg", true
  | "image/png" -> "png", true
  | "image/gif" -> "gif", true
  | "text/plain"-> "txt", false
  | "text/html" -> "html", false
  | _ -> "dat", false


class file num origin =
  let md5 = Digest.to_hex (Digest.file origin) in
  let len = size_of origin in
  let mime = Magic.file cookie origin in
  let dir' = concat dir mime in
  let dirn = concat dir' (string_of_int num) in
  let ext, rel = ext_rel_of_mime mime in
  let name = sprintf "%s-%d.%s" md5 len ext in
object(self)
  method md5 = md5
  method len = len
  method mime = mime
  method prev_dir = dirname origin
  method prev_name = basename origin
  method prev_path = origin
  method dir = dirn
  method name = name
  method path = concat dirn name
  method relevant = rel
  method mkdir = mkdir dirn
  method mv = mv self#prev_path self#path
end
 

(*let info file =
  try Left (new file file) with
      e -> Right e*)

let compose n dir acc f =
  let f' = concat dir f in
  if not (file_exists f') || is_directory f' then
    acc
  else
    (new file n f')::acc

let of_dir n dir =
  Array.fold_left (compose n dir) [] (readdir dir)
