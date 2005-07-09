(*
 * ocaml-md5sums - use and maintain debian registry of ocaml md5sums
 *
 * Copyright (C) 2005, Stefano Zacchiroli <zack@debian.org>
 *
 * Created:        Wed, 06 Apr 2005 16:55:39 +0200 zack
 * Last-Modified:  Mon, 11 Apr 2005 10:39:58 +0200 zack
 *
 * This is free software, you can redistribute it and/or modify it under the
 * terms of the GNU General Public License version 2 as published by the Free
 * Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 * Place, Suite 330, Boston, MA  02111-1307  USA
 *)

open Printf

(** {2 Constants} *)

let ocamlobjinfo = "/usr/bin/ocamlobjinfo"
let md5sums_dir = "/var/lib/ocaml/md5sums"
let md5sums_index = "MD5SUMS"
let md5sums_ext = ".md5sums"
let registry_file = sprintf "%s/%s" md5sums_dir md5sums_index

(** {2 Regular expressions, for parsing purposes} *)

let unit_name_line_RE =
  Str.regexp "^[ \t]*Unit[ \t]+name[ \t]*:[ \t]*\\([a-zA-Z0-9_]+\\)[ \t]*$"
let md5sum_line_RE =
  Str.regexp "^[ \t]*\\([a-f0-9]+\\)[ \t]+\\([a-zA-Z0-9_]+\\)[ \t]*$"
let blanks_RE = Str.regexp "[ \t]+"
let ignorable_line_RE = Str.regexp "^[ \t]*\\(#.*\\)?"
let md5sums_ext_RE = Str.regexp (sprintf "^.*%s$" (Str.quote md5sums_ext))

(** {2 Argument parsing} *)

let objects = ref []
let dev_dep = ref ""
let runtime_dep = ref "-"
let dep_version = ref "-"
let verbosity = ref 0
let dump_info_to = ref ""
let load_info_from = ref ""
let action = ref None

let usage_msg =
  "Use and maintain system wide ocaml md5sums registry\n"
  ^ "Usage:\n"
  ^ " ocaml-md5sum compute --package <name> [option ...] file ...\n"
  ^ " ocaml-md5sum dep     [option ...] file ...\n"
  ^ " ocaml-md5sum update  [option ...]\n"
  ^ "Options:"
let cmdline_spec = [
  "--package", Arg.Set_string dev_dep,
    "set package name for development dependency";
  "--runtime", Arg.Set_string runtime_dep,
    "set package name for runtime dependency";
  "--version", Arg.Set_string dep_version,
    "set package version for dependencies";
  "--dump-info", Arg.Set_string dump_info_to,
    "dump ocamlobjinfo to file";
  "--load-info", Arg.Set_string load_info_from,
    "restore ocamlobjinfo from file";
  "-v", Arg.Unit (fun () -> incr verbosity), "increase verbosity";
]
let die_usage () =
  Arg.usage cmdline_spec usage_msg;
  exit 1

(** {2 Helpers} *)

let error   msg = prerr_endline ("Error: " ^ msg); exit 2
let warning msg = prerr_endline ("Warning: " ^ msg)
let info ?(level = 1) msg =
  if !verbosity >= level then prerr_endline ("Info: " ^ msg)
let iter_in f ic =
  try while true do f (input_line ic) done with End_of_file -> ()
let iter_file f fname =
  let ic = open_in fname in
  iter_in f ic;
  close_in ic
let iter_table f = iter_file (fun line -> f (Str.split blanks_RE line))

module Strings = Set.Make (String)

(** read until the end of standard input
 * @return the list of lines read from stdin, without trailing "\n" *)
let read_stdin () =
  let lines = ref [] in
  iter_in (fun s -> lines := s :: !lines) stdin;
  List.rev !lines

(** {2 Auxiliary functions} *)

(** loads info previously stored in a file using --dump-info and stores them in
 * two hashtables
 * @param defined hashtable for md5sums of defined units
 * @param imported hashtable for md5sums of imported units
 * @param fname file where the dump has been saved *)
let load_info ~defined ~imported fname =
  info ("loading ocamlobjinfo information from " ^ fname);
  let lineno = ref 0 in
  iter_table
    (fun fields ->
      incr lineno;
      match fields with
      | [ "defined"; md5; unit_name ] ->
          info ~level:2 (String.concat " " fields);
          Hashtbl.replace defined unit_name md5
      | [ "imported"; md5; unit_name ] ->
          info ~level:2 (String.concat " " fields);
          Hashtbl.replace imported unit_name md5
      | _ ->
          warning (sprintf "ignoring dump entry (%s, line %d)" fname !lineno))
    fname

(** dumps ocamlobjinfo to file
 * @param defined hashtable containing md5sums of defined units
 * @param imported hashtable containing md5sums of imported units
 * @param fname file where to dump ocamlobjinfo *)
let dump_info ~defined ~imported fname =
  info ("dumping ocamlobjinfo information to " ^ fname);
  let oc = open_out fname in
  Hashtbl.iter
    (fun unit_name md5sum -> fprintf oc "defined  %s %s\n" md5sum unit_name)
    defined;
  Hashtbl.iter
    (fun unit_name md5sum -> fprintf oc "imported %s %s\n" md5sum unit_name)
    imported;
  close_out oc

(** @param fnames list of *.cm[ao] file names
 * @return a pair of hash tables <defined_units, imported_units>. Both tables
 * contains mappings <unit_name, md5sum>. defined_units lists units defined in
 * given files while imported_units imported ones *)
let unit_info fnames =
  let (defined, imported) = (Hashtbl.create 1024, Hashtbl.create 1024) in
  if !load_info_from <> "" then
    load_info ~defined ~imported !load_info_from;
  List.iter
    (fun fname ->
      info ("getting unit info from " ^ fname);
      let current_unit = ref "" in
      let ic = Unix.open_process_in (sprintf "%s %s" ocamlobjinfo fname) in
      iter_in
        (fun line ->
          if Str.string_match unit_name_line_RE line 0 then
            current_unit := Str.matched_group 1 line
          else if Str.string_match md5sum_line_RE line 0 then
            let md5sum = Str.matched_group 1 line in
            let unit_name = Str.matched_group 2 line in
            if unit_name = !current_unit then begin (* defined unit *)
              let dump_entry = sprintf "defined %s %s" md5sum unit_name in
              info ~level:2 dump_entry;
              Hashtbl.replace defined unit_name md5sum
            end else begin  (* imported unit *)
              let dump_entry = sprintf "imported %s %s" md5sum unit_name in
              info ~level:2 dump_entry;
              Hashtbl.replace imported unit_name md5sum
            end)
        ic;
      close_in ic)
    fnames;
  Hashtbl.iter  (* imported := imported - defined *)
    (fun unit_name _ -> Hashtbl.remove imported unit_name)
    defined;
  if !dump_info_to <> "" then
    dump_info ~defined ~imported !dump_info_to;
  (defined, imported)

(** pretty print a registry entry sending output to an output channel *)
let pp_entry outchan ~md5sum ~unit_name ~dev_dep ~runtime_dep ~dep_version =
  fprintf outchan "%s %s %s %s %s\n"
    md5sum unit_name dev_dep runtime_dep dep_version

(** iter a function over the entries of a registry file
 * @param f function to be executed for each entries, it takes 4 labeled
 * arguments: ~md5sum ~unit_name ~package ?version
 * @param fname file containining the registry *)
let iter_registry f fname =
  info ("processing registry " ^ fname);
  let lineno = ref 0 in
  iter_file
    (fun line ->
      incr lineno;
      (match Str.split blanks_RE line with
      | [ md5sum; unit_name; dev_dep; runtime_dep; dep_version ] ->
          f ~md5sum ~unit_name ~dev_dep ~runtime_dep ~dep_version
      | _ when Str.string_match ignorable_line_RE line 0 -> ()
      | _ ->
          warning (sprintf "ignoring registry entry (%s, line %d)"
            fname !lineno)))
    fname

(** @param fname file name of the registry file
 * @return an hashtbl mapping pairs <unit_name, md5sum> to pairs <package_name,
 * version_info>. E.g. ("Foo_bar", "74be7fa4320ebd9415f1c7cfc04c2d7b") ->
 * ("libfoo-ocaml-dev", ">= 1.2.3-4") *)
let parse_registry fname =
  let registry = Hashtbl.create 1024 in
  iter_registry
    (fun ~md5sum ~unit_name ~dev_dep ~runtime_dep ~dep_version ->
      Hashtbl.replace registry (unit_name, md5sum)
        (dev_dep, runtime_dep, dep_version))
    fname;
  registry

(** {2 Main functions, one for each command line action} *)

(** compute registry entry for a set of ocaml objects *)
let compute dev_dep runtime_dep dep_version objects () =
  let defined, _ = unit_info objects in
  Hashtbl.iter
    (fun unit_name md5sum ->
       pp_entry stdout ~md5sum ~unit_name ~dev_dep ~runtime_dep ~dep_version)
    defined

(** compute package dependencies for a set of ocaml objects *)
let dep objects () =
  let _, imported = unit_info objects in
  let registry = parse_registry registry_file in
  let deps =
    Hashtbl.fold
      (fun unit_name md5sum deps ->
        try
          let (dev_dep, runtime_dep, dep_version) =
            Hashtbl.find registry (unit_name, md5sum)
          in
          Strings.add (sprintf "%s %s %s" dev_dep runtime_dep dep_version) deps
        with Not_found -> deps)
      imported
      Strings.empty
  in
  Strings.iter print_endline deps

(** update debian registry of ocaml md5sums *)
let update () =
  info (sprintf "updating registry %s using info from %s/"
    registry_file md5sums_dir);
  let registry = open_out registry_file in
  let keys = Hashtbl.create 1024 in (* history of seen registry keys *)
  let dir = Unix.opendir md5sums_dir in
  try
    while true do
      let fname = sprintf "%s/%s" md5sums_dir (Unix.readdir dir) in
      if (Str.string_match md5sums_ext_RE fname 0)
        && ((Unix.stat fname).Unix.st_kind = Unix.S_REG)
      then
        iter_registry
          (fun ~md5sum ~unit_name ~dev_dep ~runtime_dep ~dep_version ->
             if Hashtbl.mem keys (unit_name, md5sum) then
               error (sprintf "duplicate entry %s %s in registry" unit_name
                          md5sum);
             Hashtbl.replace keys (unit_name, md5sum) ();
             pp_entry registry ~md5sum ~unit_name ~dev_dep ~runtime_dep
               ~dep_version)
          fname
    done
  with End_of_file ->
    Unix.closedir dir;
    close_out registry

(** {2 Main} *)

(** main *)
let main () =
  Arg.parse cmdline_spec
    (fun s ->
      if !action = None then
        action := Some s
      else
        objects := s :: !objects)
    usage_msg;
  match !action with
  | Some "update" -> update ()
  | Some action ->
      let objects =
        match !objects with
        | [] when !load_info_from = "" -> read_stdin ()
        | objects -> List.rev objects
      in
      (match action with
      | "compute" ->
          if !dev_dep = "" then die_usage ();
          compute !dev_dep !runtime_dep !dep_version objects ()
      | "dep" -> dep objects ()
      | _ -> die_usage ())
  | None -> die_usage ()

let _ = Unix.handle_unix_error main ()

