open Batteries
open Filename
open File
open Printf
open Sys

module O = Opt

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
    ext: string
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

let tmp_dir = concat repo_dir "tmp"

let mkdir_tmp_dir() = mkdir tmp_dir

let anal_mime = function
    "image/jpeg" -> true, "jpg"
  | "image/png" -> true, "png"
  | "image/gif" -> true, "gif"
  | "text/plain"-> false, "txt"
  | "text/html" -> false, "html"
  | _ -> false, "dat"

let isimg_of_mime s = fst(anal_mime s)
let ext_of_mime s = snd (anal_mime s)

let name md5 size s s2 ext =
  sprintf "%s-%Ld%s%s.%s" md5 size s s2 ext

let new_file (bag_id : int64) (pos : int) s2 origin =
  let md5 = Digest.to_hex (Digest.file origin) in
  let size = Int64.of_int (size_of origin) in
  let mime = Magic.file cookie_mime origin in
  let magic = Magic.file cookie_desc origin in
  let dir' = concat repo_dir mime in
  let dirn = concat dir' (sprintf "%Ld" bag_id) in
  let ext = ext_of_mime mime in

  let image = Image.info origin in

  let repo_name = match image with
      None -> name md5 size "" s2 ext
    | Some (w, h, _) -> name md5 size (sprintf "-%ldx%ld" w h) s2 ext in

  let path = concat dirn repo_name in

    O.p O.Alot "%s -> %s\n%!" origin path;

    {
      bag_id;
      pos = Int64.of_int pos;
      md5;
      size;
      ext;
      mime;
      magic;
      prev_name = basename origin;
      prev_dir = dirname origin;
      prev_path = origin;
      dir = dirn;
      name = repo_name;
      path;
      image
    }

let write_thumbnail callback max_w max_h
    { bag_id; md5; size; ext; prev_path; dir; image } =

  let p_w, p_h = match image with
      None -> raise (Failure "write_thumbnail")
    | Some (w, h, _) -> w, h in

  let p = concat tmp_dir "thumbnail.jpg" in
  match Image.r max_w max_h prev_path (fun w h -> p) with
      None -> ()
    | Some (n, _, _) ->
        let s2 = sprintf "-thumbnail-%s-%Ld-%ldx%ld" md5 size p_w p_h in

        let file = new_file bag_id 0 s2 n in
          callback file max_w max_h (* gambiarra; vai adicionar ao db,
                                       e remover o arquivo.. *)

let add_thumbnails callback sizes file =
  if isimg_of_mime file.mime then
    List.iter (fun (w, h) -> write_thumbnail callback w h file) sizes

let mkdir_f file =
  mkdir file.dir

let link_f file =
  link file.prev_path file.path 

let mv_f file =
  Sys.rename file.prev_path file.path

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
    (new_file bag_id i "" f')::acc

let of_dir bag_id files dir =
  Array.fold_lefti (compose bag_id dir) [] files

let mkdir_l l = List.iter (fun x -> mkdir_f x) l

