
open Printf

(** {2 Constants} *)

let ocamlobjinfo = "/usr/bin/ocamlobjinfo"
let md5sums_dir = "/var/lib/ocaml/md5sums"
let md5sums_index = "MD5SUMS"
let md5sums_ext = ".md5sums"
let registry_file = sprintf "%s/%s" md5sums_dir md5sums_index

(** {2 Regular expressions, for parsing} *)

let unit_name_RE =
  Str.regexp "^[ \\t]*Unit[ \\t]+name[ \\t]*:[ \\t]*\\([a-zA-Z0-9_]+\\)[ \\t]*$"
let md5sum_RE =
  Str.regexp "^[ \\t]*\\([a-z0-9]+\\)[ \\t]+\\([a-zA-Z0-9_]+\\)[ \\t]*$"
let blanks_RE = Str.regexp "[ \\t]+"

(** {2 Argument parsing} *)

let objects = ref []
let pkg_version = ref ""
let pkg_name = ref ""
let action = ref None

let usage_msg =
  "Use and maintain system registry of ocaml md5sums\n"
  ^ "Usage:\n"
  ^ "  ocaml-md5sum compute --package [name] --version [version] object ...\n"
  ^ "  ocaml-md5sum dep     --package [name] --version [version] object ...\n"
  ^ "  ocaml-md5sum update\n"
  ^ "Options:"
let cmdline_spec = [
  "--package", Arg.Set_string pkg_name,
    "set package name (required by compute and dep actions)";
  "--version", Arg.Set_string pkg_version,
    "set package version (required by compute and dep actions)";
]
let die_usage () =
  Arg.usage cmdline_spec usage_msg;
  exit 1

(** {2 Auxiliary functions} *)

let warning msg = prerr_endline ("Warning: " ^ msg)

let error msg =
  prerr_endline ("Error: " ^ msg);
  exit 2

(** @param fnames list of *.cm[ao] file names
 * @return a pair of hash tables <defined_units, imported_units>. Both tables
 * contains mappings <unit_name, md5sum>. defined_units lists units defined in
 * given files while imported_units imported ones *)
let unit_info fnames =
  let (defined, imported) = (Hashtbl.create 1024, Hashtbl.create 1024) in
  List.iter
    (fun fname ->
      let ic = Unix.open_process_in (sprintf "%s %s" ocamlobjinfo fname) in
      let unit_name = ref "" in
      try
        while true do
         let line = input_line ic in
         if Str.string_match unit_name_RE line 0 then
           unit_name := Str.matched_group 1 line
         else if Str.string_match md5sum_RE line 0 then
          let unit_name' = Str.matched_group 2 line in
          let tbl = if unit_name' = !unit_name then defined else imported in
          Hashtbl.replace tbl unit_name' (Str.matched_group 1 line)
        done
      with End_of_file -> close_in ic)
    fnames;
  Hashtbl.iter  (* imported := imported - defined *)
    (fun unit_name _ -> Hashtbl.remove imported unit_name)
    defined;
  (defined, imported)

(** @param fname file name of the registry file
 * @return an hashtbl mapping pairs <unit_name, md5sum> to pairs <package_name,
 * version_info>. E.g. ("Foo_bar", "74be7fa4320ebd9415f1c7cfc04c2d7b") ->
 * ("libfoo-ocaml-dev", ">= 1.2.3-4") *)
let parse_registry fname =
  let registry = Hashtbl.create 1024 in
  let ic = open_in fname in
  let n = ref 0 in
  (try
    while true do
      incr n;
      let line = input_line ic in
      (match Str.split blanks_RE line with
      | [ md5sum; unit_name; package; version ] ->
          Hashtbl.replace registry (unit_name, md5sum) (package, version)
      | _ ->
          warning (sprintf "ignoring registry entry (%s:%d)" registry_file !n))
    done
  with End_of_file -> close_in ic);
  registry

(** {2 Main functions, one for each command line action} *)

let compute ~package ~version () =
  if (package = "" || version = "") then die_usage ();
  let defined, _ = unit_info !objects in
  Hashtbl.iter
    (fun unit_name md5sum ->
      printf "%s %s %s %s\n" md5sum unit_name package version)
    defined

let dep ~package ~version () =
  if (package = "" || version = "") then die_usage ();
  let _, imported = unit_info !objects in
  let registry = parse_registry registry_file in
  Hashtbl.iter
    (fun unit_name md5sum ->
      try
        let (package, version) = Hashtbl.find registry (unit_name, md5sum) in
        printf "%s %s\n" package version
      with Not_found -> ())
    imported

let update () = failwith "not implemented"  (* TODO *)

(** {2 Main} *)

let main () =
  Arg.parse cmdline_spec
    (fun s ->
      if !action = None then
        action := Some s
      else
        objects := s :: !objects)
    usage_msg;
  objects := List.rev !objects;
  let package, version = !pkg_name, !pkg_version in
  match !action with
  | Some "compute" -> compute ~package ~version ()
  | Some "dep" -> dep ~package ~version ()
  | Some "update" -> update ()
  | _ -> die_usage ()

let _ = main ()

