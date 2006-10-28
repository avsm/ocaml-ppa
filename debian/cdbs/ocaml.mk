#
# Description: CDBS class for OCaml related packages
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
# $Id: ocaml.mk 3288 2006-10-28 13:40:52Z zack $

_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class

ifndef _cdbs_class_ocaml
_cdbs_class_ocaml = 1

# needed by debian/control:: rule below
include $(_cdbs_rules_path)/buildcore.mk$(_cdbs_makefile_suffix)

# to ensure invocations and tests on /usr/bin/ocaml* are meaningful
CDBS_BUILD_DEPENDS := $(CDBS_BUILD_DEPENDS), ocaml-nox

# import OCAML_* make variables
include $(_cdbs_class_path)/ocaml-vars.mk$(_cdbs_makefile_suffix)

# ensure dpkg-gencontrol will fill F:OCamlABI fields with the proper value
ifdef _cdbs_rules_debhelper
DEB_DH_GENCONTROL_ARGS += -- -VF:OCamlABI="$(OCAML_ABI)"
DEB_DH_GENCONTROL_ARGS +=    -VF:OCamlNativeArchs="$(OCAML_NATIVE_ARCHS)"
endif

# generate .in files counterpars before building, substituting @OCamlABI@
# markers with the proper value; clean stamps after building
pre-build:: ocamlinit
ocamlinit: ocamlinit-stamp
ocamlinit-stamp:
	for f in $(OCAML_IN_FILES) ; do \
		sed \
			-e 's,@OCamlABI@,$(OCAML_ABI),g' \
			-e 's,@OCamlStdlibDir@,$(OCAML_STDLIB_DIR),g' \
			$$f.in > $$f ; \
	done
	touch $@
clean::
	rm -f ocamlinit-stamp

# update debian/control substituting @OCamlNativeArchs@
# XXX ASSUMPTION: debian/control has already been generated, i.e. this rule is
# executed after the debian/control:: rule in builcore.mk
ifneq ($(DEB_AUTO_UPDATE_DEBIAN_CONTROL),)
debian/control::
	if test -f debian/control && test -f debian/control.in ; then \
		sed -i \
			-e "s/@OCamlNativeArchs@/$(OCAML_NATIVE_ARCHS)/g" \
			-e "s/@OCamlTeam@/$(OCAML_TEAM)/g" \
			$@ ; \
	fi
endif

endif

