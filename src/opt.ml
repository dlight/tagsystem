open Batteries
open Printf
open Arg


type verbose = Not | Abit | Alot

let string_of_verbose = function
    Not -> "Not"
  | Abit -> "Abit"
  | Alot -> "Alot"

let (>=$) a b = match a, b with
    Alot, _   | Abit, Abit
  | Abit, Not | Not, Not -> true
  | _ -> false

let verb = ref Not
let arg = ref []

let p v' =
  if !verb >=$ v' then
    printf
  else
    fprintf stdnull

let parse () =
  let l =
    handle ~usage:"This is ts-add\n"
      [command ~doc:"verbose" "-v" (Unit (fun () -> verb := Abit));
       command ~doc:"more verbose" "-vv" (Unit (fun () -> verb := Alot));
       command "--" (Rest (fun l -> arg := l :: !arg))] in
    arg := l @ !arg

