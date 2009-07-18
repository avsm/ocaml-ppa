
EXE=ocamlbyteinfo
OCAMLC=./ocamlc

DEPS=utils/misc.cmo utils/tbl.cmo \
  utils/config.cmo utils/clflags.cmo \
  typing/ident.cmo typing/path.cmo typing/types.cmo typing/btype.cmo \
  typing/predef.cmo bytecomp/instruct.cmo bytecomp/runtimedef.cmo bytecomp/bytesections.cmo \
  bytecomp/dll.cmo bytecomp/meta.cmo bytecomp/symtable.cmo

INCLUDES= -I stdlib -I utils -I typing -I bytecomp

all: $(EXE)

$(EXE): $(DEPS)
	$(OCAMLC) -o debian/$(EXE)/$(EXE) $(INCLUDES) $(DEPS) debian/$(EXE)/$(EXE).ml

clean:
	rm -f $(addprefix debian/$(EXE)/, $(EXE) $(EXE).cmo $(EXE).cmi)
