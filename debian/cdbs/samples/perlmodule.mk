# -*- mode: makefile; coding: utf-8 -*-
# Copyright © 2003 Colin Walters <walters@debian.org> and Jonas
# Smedegaard <dr@jones.dk>
# Description: Configures, builds, and cleans Perl modules
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307 USA.

_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class

ifndef _cdbs_class_perlmodule
_cdbs_class_perlmodule = 1

# Make sure that CDBS_BUILD_DEPENDS is initialised
include $(_cdbs_rules_path)/buildvars.mk$(_cdbs_makefile_suffix)

# Dependency according to Perl policy 4.3
# (contrary to common misunderstanding a tighter dependency on perl 5.8
# was only temporarily needed when 5.8 was introduced into Debian sid.)
CDBS_BUILD_DEPENDS := $(CDBS_BUILD_DEPENDS), perl (>= 5.6.0-16)

include $(_cdbs_class_path)/perlmodule-vars.mk$(_cdbs_makefile_suffix)

include $(_cdbs_class_path)/makefile.mk$(_cdbs_makefile_suffix)

DEB_MAKEMAKER_PACKAGE ?= tmp

ifneq ($(DEB_BUILDDIR),$(DEB_SRCDIR))
$(error DEB_BUILDDIR and DEB_SRCDIR must be the same for Perl builds.)
endif

common-configure-arch common-configure-indep:: Makefile
Makefile:
	(cd $(DEB_BUILDDIR) && $(DEB_MAKEMAKER_INVOKE) $(DEB_MAKEMAKER_USER_FLAGS) )

endif
