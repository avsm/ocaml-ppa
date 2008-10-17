#!/bin/sh
# $Id: ocamlbuildlib-native-only.sh,v 1.2 2007/11/27 12:21:53 ertai Exp $
set -e
OCAMLBUILD_PARTIAL="true"
export OCAMLBUILD_PARTIAL
cd `dirname $0`/..
. build/targets.sh
set -x
$OCAMLBUILD $@ native_stdlib_partial_mode $OCAMLOPT_BYTE $OCAMLLEX_BYTE $OCAMLBUILDLIB_NATIVE
