
DIR=debian/ocamlbyteinfo
BEXE=ocamlbyteinfo
NEXE=ocamlplugininfo
OCAMLC=./boot/ocamlrun ./ocamlc
OCAMLOPT=./boot/ocamlrun ./ocamlopt
OCAMLLEX=./boot/ocamlrun ./lex/ocamllex

GENERATED=$(BEXE) $(NEXE) *.cm* natdynlink.* *.a *.o

BDEPS=otherlibs/dynlink/dynlinkaux.cmo
NDEPS=$(DIR)/natdynlink.cmxa
INCLUDES= -I stdlib -I utils -I typing -I bytecomp -I $(DIR) \
  -I otherlibs/dynlink -I otherlibs/unix -I otherlibs/str

all: $(BEXE) $(NEXE)

$(DIR)/natdynlink.ml:
	cp otherlibs/dynlink/natdynlink.ml $(DIR)/

$(DIR)/natdynlink.cmx: $(DIR)/natdynlink.ml
	$(OCAMLOPT) -c $(INCLUDES) $(DIR)/natdynlink.ml

$(DIR)/natdynlink.cmxa: $(DIR)/natdynlink.cmx
	$(OCAMLOPT) $(INCLUDES) -ccopt "-Wl,-E" $^ -a -o $@

$(NEXE): $(NDEPS)
	$(OCAMLOPT) unix.cmxa str.cmxa -o $(DIR)/$(NEXE) $(INCLUDES) $(NDEPS) $(DIR)/$(NEXE).ml

$(BEXE): $(BDEPS)
	$(OCAMLC) -o $(DIR)/$(BEXE) $(INCLUDES) $(BDEPS) $(DIR)/$(BEXE).ml

clean:
	rm -f $(addprefix $(DIR)/, $(GENERATED))
