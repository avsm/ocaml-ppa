
(*
 * Copyright (C) 2009 Mehdi Dogguy
 * You have permission to copy, modify, and redistribute under the
 * terms of the LGPL-2.1.
 *)

open Sys

let get_string_list sect len =
  let rec fold s e acc =
    if e != len then
      if sect.[e] = '\000' then
        fold (e+1) (e+1) (String.sub sect s (e-s) :: acc)
      else fold s (e+1) acc
    else acc
  in fold 0 0 []

let input_stringlist ic len =
  let sect = String.create len in
  let _ = really_input ic sect 0 len in
    get_string_list sect len

let print = Printf.printf

type prefix = C | P | M | S | R | D
let p_prefix = function
  | C -> "DLLS"
  | M -> "UNIT"
  | P -> "DLPT"
  | S -> "SYMB"
  | R -> "PRIM"
  | D -> "DBUG"

let p_section prefix =
  List.iter
    (fun name -> print "%s %s\n" (p_prefix prefix) name)

let _ =
  let input_name = Sys.argv.(1) in
  let ic = open_in_bin input_name in
  let _ = Bytesections.read_toc ic in
  let toc = Bytesections.toc () in
    List.iter
      (fun (sec, len) ->
         if len > 0 then
           let _ = Bytesections.seek_section ic sec in
             match sec with
               | "CRCS" ->
                   let crcs = (input_value ic : (string * Digest.t) list)
                   in List.iter
                        (fun (name, dig) -> print "%s %s %s\n"
                           (p_prefix M)
                           (Digest.to_hex dig)
                           name
                        ) crcs
               | "DLLS" -> p_section C (input_stringlist ic len)
               | "DLPT" -> p_section P (input_stringlist ic len)
               | "SYMB" ->
                   let (_, sym_table) = (input_value ic
                                           : int * (Ident.t, int) Tbl.t)
                   in let list = ref []
                   in let _ = Tbl.map
                       (fun id pos -> list := (id,pos) :: !list) sym_table
                   in List.iter (fun (id, pos) -> print "%s %.10d %s\n"
                                   (p_prefix S)
                                   pos
                                   (Ident.name id))
                        (List.sort
                           (fun (_, pos) (_,pos') -> Pervasives.compare pos pos')
                           !list)
               | "PRIM" -> p_section R (input_stringlist ic len)
               | _ -> ()
      )
      toc;
    close_in ic
