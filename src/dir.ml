open Batteries
open Filename
open File
open Printf
open Sys



module File =
struct
  type file = {
    dir : string;
    image : (int32 * int32 * int32) option;
    magic : string;
    md5 : string;
    mime : string;
    name : string;
    path : string;
    pos : int64;
    prev_dir : string;
    prev_name : string;
    prev_path : string;
    bag_id : int64;
    size : int64;
  }
end

open File

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

let ext_of_mime = function
    "image/jpeg" -> "jpg"
  | "image/png" -> "png"
  | "image/gif" -> "gif"
  | "text/plain"-> "txt"
  | "text/html" -> "html"
  | _ -> "dat"

let name md5 size ext is_thumb info =
  match is_thumb, info with
    false, Some (h, w, _) ->
      sprintf "%s-%Ld-%ldx%ld.%s" md5 size h w ext
  | true, Some (h, w, _) ->
      sprintf "%s-%Ld-thumbnail-%ldx%ld.%s" md5 size h w ext
  | _ ->
      sprintf "%s-%Ld.%s" md5 size ext

let new_file bag_id origin pos =
  let md5 = Digest.to_hex (Digest.file origin) in
  let size = Int64.of_int (size_of origin) in
  let mime = Magic.file cookie_mime origin in
  let magic = Magic.file cookie_desc origin in
  let dir' = concat repo_dir mime in
  let dirn = concat dir' (sprintf "%Ld" bag_id) in
  let ext = ext_of_mime mime in

  let image = Image.info origin in

  let repo_name = name md5 size ext false image in

    {
      bag_id;
      pos = Int64.of_int pos;
      md5;
      size;
      mime;
      magic;
      prev_name = basename origin;
      prev_dir = dirname origin;
      prev_path = origin;
      dir = dirn;
      name = repo_name;
      path = concat dirn repo_name;
      image
    }

let mkdir_f file =
  mkdir file.dir

let link_f file =
  link file.prev_path file.path 

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

let compose bag_id dir acc i f =
  let f' = concat dir f in
    (new_file bag_id f' i)::acc

let of_dir bag_id files dir =
  Array.fold_lefti (compose bag_id dir) [] files

let mkdir_l l = List.iter (fun x -> mkdir_f x) l

