#!/bin/sh
# $Id: world.sh,v 1.3 2007/10/08 14:19:34 doligez Exp $
cd `dirname $0`
set -ex
./mkconfig.sh
./mkmyocamlbuild_config.sh
. ../config/config.sh
if [ "x$EXE" = "x.exe" ]; then
  ./boot-c-parts-windows.sh
else
  ./boot-c-parts.sh
fi
./boot.sh $@
./world.all.sh $@
