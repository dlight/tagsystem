open Batteries
open Filename
open File
open Printf
open Sys

(* I may remove this dependency *)
let mkdir dir = FileUtil.mkdir ~parent:true dir

(*let mv = FileUtil.mv*)

let link a b =
  try Unix.link a b with
      Unix.Unix_error (Unix.EEXIST, _, _) -> ()

(*type ('a, 'b) either = Left of 'a | Right of 'b*)

let cookie_mime = Magic.make ~flags:[Magic.Mime] []
let cookie_desc = Magic.make []

let repo_dir = concat (getenv "HOME") "files"

let ext_rel_of_mime = function
    "image/jpeg" -> "jpg", true
  | "image/png" -> "png", true
  | "image/gif" -> "gif", true
  | "text/plain"-> "txt", false
  | "text/html" -> "html", false
  | _ -> "dat", false


class file num origin (pos : int) =
  let md5 = Digest.to_hex (Digest.file origin) in
  let size = size_of origin in
  let mime = Magic.file cookie_mime origin in
  let magic = Magic.file cookie_desc origin in
  let dir' = concat repo_dir mime in
  let dirn = concat dir' (sprintf "%Ld" num) in
  let ext, rel = ext_rel_of_mime mime in
  let name = sprintf "%s-%d.%s" md5 size ext in
object(self)
  method set_id = num
  method pos = Int64.of_int pos
  method md5 = md5
  method size = Int64.of_int size
  method mime = mime
  method magic = magic
  method prev_dir = dirname origin
  method prev_name = basename origin
  method prev_path = origin
  method dir = dirn
  method name = name
  method path = concat dirn name
  method image = rel
  method mkdir = mkdir dirn
  method link = link self#prev_path self#path
end
 

(*let info file =
  try Left (new file file) with
      e -> Right e*)

let readlink f =
  try Some (Unix.readlink f) with
      Unix.Unix_error (Unix.EINVAL, "readlink", _) -> None

let rec sym_dir f =
  if not (file_exists f) then
    false
  else if is_directory f then
    true else
    match readlink f with
        Some f -> sym_dir f
      | None -> false

let files dir =
  let a = Array.filter (fun f -> let f' = concat dir f in
                  file_exists f'
                  && not (sym_dir f')) (readdir dir) in
    Msort.sort a;
    a

let compose n dir acc i f =
  let f' = concat dir f in
    (new file n f' i)::acc

let of_dir n files dir =
  Array.fold_lefti (compose n dir) [] files

let mkdir_l l = List.iter (fun x -> x#mkdir) l

