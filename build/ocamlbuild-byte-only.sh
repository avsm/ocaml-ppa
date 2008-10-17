#!/bin/sh
# $Id: ocamlbuild-byte-only.sh,v 1.3 2007/10/08 14:19:34 doligez Exp $
set -e
OCAMLBUILD_PARTIAL="true"
export OCAMLBUILD_PARTIAL
cd `dirname $0`/..
. build/targets.sh
set -x
$OCAMLBUILD $@ byte_stdlib_partial_mode $OCAMLC_BYTE $OCAMLLEX_BYTE $OCAMLBUILD_BYTE
