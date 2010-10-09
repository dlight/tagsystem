(** Hello
  * for extension see http://sql.pastebin.com/SWSwx1ss *)

open Batteries
open Printf

(** Internalized files *)
type file = {
  fid : int32;      (** File id *)
  path : string     (** Unique path for the file *)
}

(** Set of files *)
type set = {
  sid : int32       (** Set id *)
}


(** Maps a (set, position) pair to a file *)
module M = struct
  include Map.Make (struct
                      type t = set * int32
                      let compare = compare end)

  (** Prints a file *)
  let print_key o (s, e) =
    fprintf o "(%ld, %ld)" s.sid e

  (** Prints a file *)
  let print_file o f =
    fprintf o "{ %ld, %s }" f.fid f.path

  (** Prints a map *)
  let print m = print print_key print_file stdout m
end
(** Nicer interface to database *)
module D = struct
  let connect () = PGOCaml.connect ()

  let insert_file = Db.insert_file
  let insert_set = Db.insert_set

  let insert_rel = Db.insert_set_file

  (** Make a query for all (set, pos, file) tuples, then convert
    * into a map *)
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

