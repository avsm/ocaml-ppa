#!/bin/sh
# Copyright (C) 2005, Stefano Zacchiroli <zack@debian.org>
#
# This is free software, you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free
# Software Foundation.

pkg="$1"
stdlibdir="$2"
version="$3"
rootdir="$4"
SORT="sort -k 2"
if [ -x ./ocaml-md5sums.opt ]; then
  OCAML_MD5SUMS="./ocaml-md5sums.opt"
elif [ -x ./ocaml-md5sums ]; then
  OCAML_MD5SUMS="./ocaml-md5sums"
else
  echo "Can't find ocaml-md5sums{.opt,}, aborting."
  exit 2
fi
export OCAMLOBJINFO="../../boot/ocamlrun ../../tools/objinfo"
COMPUTE="$OCAML_MD5SUMS compute --package $pkg-$version"
if [ -z "$pkg" ] || [ -z "$stdlibdir" ] || [ -z "$version" ] || [ -z "$rootdir" ]; then
  echo "Usage: feeding.sh <pkg_name> <stdlib_dir> <ocaml_version> <root_dir>"
  exit 1
fi
case "$pkg" in
  ocaml-compiler-libs)
    find $rootdir -name "*.cm[ao]" | $COMPUTE | $SORT
    ;;
  *)
    RUNTIME="`echo $pkg | sed 's/ocaml/ocaml-base/'`-$version"
    find $rootdir -name "*.cm[ao]" |
      grep -v $stdlibdir/ocamldoc/ |
      grep -v $stdlibdir/camlp4/ |
      $COMPUTE --runtime $RUNTIME |
      $SORT
    ;;
esac

