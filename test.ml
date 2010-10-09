(* for extension see http://sql.pastebin.com/SWSwx1ss

*)

open Batteries
open Printf

type file = {
  fid : int32;
  path : string
}

let print_file o f =
  fprintf o "{ %ld, %s }" f.fid f.path

type set = {
  sid : int32
}

let print_key o (s, e) =
  fprintf o "(%ld, %ld)" s.sid e

module M = struct
  include Map.Make (struct type t = set * int32 let compare = compare end)
  let print m = print print_key print_file stdout m
end




module D = struct
  let connect () = PGOCaml.connect ()

  let create = Db.create_db
  let insert_file = Db.insert_file
  let insert_set = Db.insert_set

  let insert_rel = Db.insert_set_file

  let read db =
    let tuple_to_record acc (sid, pos, fid, path) =
    M.add ({ sid = sid }, pos) { fid = fid; path = path } acc in
      List.fold_left tuple_to_record M.empty (Db.get_set_file db)
end

let _ =
  let db = D.connect() in

  let i = D.insert_file db "/test" in
    List.iter (printf "aa %ld") i;
    M.print (D.read db)
