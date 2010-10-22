open Unix
open CalendarLib
open Printer.CalendarPrinter
open Time_Zone
open Calendar

open Printf

let conv c =
  let c' = from_unixfloat c in
    convert c' UTC Local

let min = List.fold_left (fun x y -> if compare x y < 0 then x else y)

let now () = convert (now()) UTC Local

let min_now l =
  let n = now() in
  let m = min n l in
    m, n

let file f =
    let s = Unix.stat f in
    let a, m, c = s.st_atime, s.st_mtime, s.st_ctime in
      (conv a, conv m, conv c)

let min_now_file f =
  let a, m, c = file f in
  let min_t, now_t = min_now [a; m; c] in
    (min_t, now_t, a, m, c)


let p (min_t, now_t, a, m, c) =
  printf "Min: %s\nNow: %s\nAtime: %s\nMtime: %s\nCtime: %s\n"
    (to_string min_t) (to_string now_t)
    (to_string a) (to_string m) (to_string c)

let s' f = p (min_now_file f)
