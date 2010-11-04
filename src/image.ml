open Batteries
open Magick

let flip (a, b) = (b, a)

let res m (a, b) =
  if (a <= m) then
    (a, b)
  else 
    (m, b * m / a)

let new_size (mw, mh) ((w, h) as p) =
  if (w * mh >= mw * h) then
    res mw p
  else
    flip (res mh (flip p))

let size h = get_image_width h, get_image_height h

let open_image file =
  if file = "" then
    None
  else
    try Some (read_image ~filename:file) with
        Failure _ -> None

let resize' maxw maxh img f =
  let w, h = new_size (maxw, maxh) (size img) in
  let img' = Fun.resize ~width:w ~height:h ~filter:Lanczos ~blur:1.0 () img in
    Imper.set_compression_quality img' 85;
    let w', h' = Int32.of_int w, Int32.of_int h in
    let n = f w' h' in
    write_image img' n;
    (n, w', h')

(* Example: r 300 300 "/q/a/01.jpg" (sprintf "/q/ahm-%ldx%ld.jpg") *)

let r maxw maxh file f =
  match open_image file with
      None -> None
    | Some handler -> Some (resize' maxw maxh handler f)

let info f =
  try
    let w, h, depth, colors, quality, mime = ping_image_infos f in

      Some (Int32.of_int w, Int32.of_int h, Int32.of_int quality)
 with
      Failure _ -> None
