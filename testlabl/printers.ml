(* $Id: printers.ml,v 1.1 2003/04/03 02:16:20 garrigue Exp $ *)

open Types

let ignore_abbrevs ppf ab =
  let s = match ab with
    Mnil -> "Mnil"
  | Mlink _ -> "Mlink _"
  | Mcons _ -> "Mcons _"
  in
  Format.pp_print_string ppf s
