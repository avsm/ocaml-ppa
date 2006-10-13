#
# Description: Useful CDBS variables for OCaml related packages
#
# Copyright © 2006 Stefano Zacchiroli <zack@debian.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# $Id: ocaml-vars.mk 3237 2006-10-13 08:27:10Z zack $

_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class

ifndef _cdbs_class_ocaml_vars
_cdbs_class_ocaml = 1

# current OCaml ABI version (ATM 3.09.2).
# Used internally by ocaml.mk (substituted for @OCamlABI@ in $(OCAML_IN_FILES)
# below), may be useful to debian/rules writers as well
OCAML_ABI := $(shell /usr/bin/ocamlc -version)

# OCaml standard library location.
# Used internally by ocaml.mk (substituted for @OCamlStdlibDir@ in
# $(OCAML_IN_FILES) below), may be useful to debian/rules writers as well
OCAML_STDLIB_DIR := $(shell /usr/bin/ocamlc -where)

# list of .in files contained (non-recursively) in debian/ that requires
# pre-build filling.
# Used internally by ocaml.mk.
# debian/rules writers might need to add stuff to this list:
#  e.g.: OCAML_IN_FILES += debian/patches/foo.in
OCAML_IN_FILES := $(filter-out debian/control,$(patsubst %.in,%,$(wildcard debian/*.in)))

# 'yes' if native code compilation is available on the build architecture, 'no' otherwise.
# For debian/rules writers.
OCAML_HAVE_OCAMLOPT := $(shell if test -x /usr/bin/ocamlopt ; then echo "yes" ; else echo "no" ; fi)

# space separated list of Debian architectures supporting OCaml native code
# compilation.
# Used internally by ocaml.mk and substituted in debian/control.in for the
# @OCamlNativeArchs@ marker; may be useful to debian/rules writers as well
OCAML_NATIVE_ARCHS := $(shell cat $(OCAML_STDLIB_DIR)/native-archs)

# comma separated list of members of the OCaml team.
# Substituted in debian/control.in for the @OCamlTeam@ marker
OCAML_TEAM =

OCAML_TEAM += Julien Cristau <julien.cristau@ens-lyon.org>,
OCAML_TEAM += Ralf Treinen <treinen@debian.org>,
OCAML_TEAM += Remi Vanicat <vanicat@debian.org>,
OCAML_TEAM += Samuel Mimram <smimram@debian.org>,
OCAML_TEAM += Stefano Zacchiroli <zack@debian.org>,
OCAML_TEAM += Sven Luther <luther@debian.org>,
OCAML_TEAM += Sylvain Le Gall <gildor@debian.org>
# no trailing "," (comma) on the last name

endif

