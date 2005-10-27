(***********************************************************************)
(*                                                                     *)
(*                           Objective Caml                            *)
(*                                                                     *)
(*          Jerome Vouillon, projet Cristal, INRIA Rocquencourt        *)
(*          Objective Caml port by John Malecki and Xavier Leroy       *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* $Id: show_source.mli,v 1.4 2005/08/25 15:35:16 doligez Exp $ *)

(* Print the line containing the point *)
val show_point : Instruct.debug_event -> bool -> unit;;

(* Tell Emacs we are nowhere in the source. *)
val show_no_point : unit -> unit;;

(* Display part of the source. *)
val show_listing : string -> int -> int -> int -> bool -> unit;;
