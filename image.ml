type either = Maxh of int | Maxw of int

let resize (h, w) = function
    Maxh h' when h <= h' -> (h, w)
  | Maxw w' when w <= w' -> (h, w)
  | Maxh h'              -> h', (w * h') / h
  | Maxw w'              -> (h * w') / w, w'

let resize_h maxh h w =
  if h <= maxh then
    (h, w)
  else
    maxh, (w*maxh) / h

let resize_w maxw h w =
  if w <= maxw then
    (h, w)
  else
    (h*maxw) / w, maxw


let resize maxh maxw h w =
  [resize_h maxh h w; resize_w maxw h w]
