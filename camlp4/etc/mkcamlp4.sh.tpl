#!/bin/sh
# $Id: mkcamlp4.sh.tpl,v 1.5 2003/07/10 12:28:19 michel Exp $

OLIB=`ocamlc -where`
LIB=LIBDIR/camlp4

INTERFACES=
OPTS=
INCL="-I ."
while test "" != "$1"; do
    case $1 in
    -I) INCL="$INCL -I $2"; shift;;
    *)
        j=`basename $1 .cmi`
        if test "$j.cmi" = "$1"; then
            first="`expr "$j" : '\(.\)' | tr 'a-z' 'A-Z'`"
            rest="`expr "$j" : '.\(.*\)'`"
            INTERFACES="$INTERFACES $first$rest"
        else
            OPTS="$OPTS $1"
        fi;;
    esac
    shift
done
