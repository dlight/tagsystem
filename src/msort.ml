open Batteries
open Str

let f x =
  match Enum.get (search (regexp "[0-9]+") x) with
      None -> None
    | Some (_, _, a) -> Some (int_of_string a)

let comp a b =
  match f a, f b with
      None, Some a -> 1
    | Some a, None -> -1
    | None, None -> compare a b
    | Some a', Some b' ->
        let c = compare a' b' in
          if c = 0 then compare a b else c

let sort q =
  Array.sort comp q (* ~cmp:(fun x y -> comp x#prev_name y#prev_name) q*)
