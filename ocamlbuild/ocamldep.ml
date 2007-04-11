(***********************************************************************)
(*                             ocamlbuild                              *)
(*                                                                     *)
(*  Nicolas Pouillard, Berke Durak, projet Gallium, INRIA Rocquencourt *)
(*                                                                     *)
(*  Copyright 2007 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* $Id: ocamldep.ml,v 1.2 2007/02/08 16:53:39 ertai Exp $ *)
(* Original author: Nicolas Pouillard *)
open My_std
open Log
open Command
open Tags.Operators
open Tools
open Ocaml_utils
open Pathname.Operators

exception Error of string

let ocamldep_command arg =
  let tags = tags_of_pathname arg++"ocaml"++"ocamldep" in
  S [!Options.ocamldep; T tags; ocaml_ppflags tags;
     flags_of_pathname arg; A "-modules"]

let menhir_ocamldep_command arg out =
  let tags = tags_of_pathname arg++"ocaml"++"menhir_ocamldep" in
  Cmd (S [!Options.ocamlyacc; T tags; A"--raw-depend";
          A"--ocamldep"; Quote (ocamldep_command arg);
          P arg; Sh ">"; Px out])

let ocamldep_command arg out =
  Cmd (S[ocamldep_command arg; P arg; Sh ">"; Px out])

let module_dependencies = Hashtbl.create 103
let module_dependencies_of module_path =
  try Hashtbl.find module_dependencies module_path with Not_found -> []
let register_module_dependencies module_path deps =
  let deps' = List.fold_right begin fun dep acc ->
    match module_importance module_path dep with
    | `ignored -> acc
    | (`just_try | `mandatory) as importance -> (importance, dep) :: acc
  end deps [] in
  Hashtbl.replace module_dependencies module_path
    (List.union (module_dependencies_of module_path) deps')

let depends name ?tags ~prod ~dep ?insert ?(ocamldep_command=ocamldep_command) () =
  Rule.custom_rule name ?tags ~prod ~dep ?insert
    ~cache:(fun env -> Command.to_string (ocamldep_command (env dep) (env prod)))
    begin fun env ~cached ->
      let arg = env dep in
      let out = env prod in
      let cmd = ocamldep_command arg out in
      let () = dprintf 6 "ocamldep: %a %a" Pathname.print arg Command.print cmd in
      if not (Pathname.exists arg) then
        raise (Error(sbprintf "Ocamldep.ocamldep: no input file (%a)" Pathname.print arg))
      else begin
        Command.execute ~pretend:cached cmd;
        with_input_file out begin fun ic ->
          let ocamldep_output =
            try Lexers.ocamldep_output (Lexing.from_channel ic)
            with Lexers.Error msg -> raise (Error(Printf.sprintf "Ocamldep.ocamldep: bad output (%s)" msg)) in
          let ocamldep_output =
            List.fold_right begin fun (_, deps) acc ->
              List.union deps acc
            end ocamldep_output [] in
         let ocamldep_output =
            if !Options.nostdlib && not (Tags.mem "nopervasives" (tags_of_pathname arg)) then
              "Pervasives" :: ocamldep_output
            else ocamldep_output in
          register_module_dependencies arg ocamldep_output
        end
      end
    end
