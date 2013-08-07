#!/bin/sh -e
curl -OL https://github.com/ocaml/ocaml/archive/4.01.tar.gz
file=ocaml_4.00.2+SNAPSHOT`date +%Y%m%d`.orig.tar
mv 4.01.tar.gz ${file}.gz
gunzip ${file}.gz
bzip2 -9 ${file}
