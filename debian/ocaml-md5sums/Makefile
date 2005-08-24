
DESTDIR = /usr/local/bin
OFLAGS = -nostdlib -I ../../stdlib -I ../../otherlibs/unix -I ../../otherlibs/str
OCAMLC = ../../boot/ocamlrun ../../ocamlc $(OFLAGS)
OCAMLOPT = ../../boot/ocamlrun ../../ocamlopt $(OFLAGS)
OCAML_LIBS = unix str
NAME = ocaml-md5sums
BYTE = $(NAME)
OPT = $(NAME).opt

all: $(BYTE)
opt: $(OPT)
install:
	if [ -x "$(OPT)" ]; then				\
		cp -a "$(OPT)" $(DESTDIR)/$(NAME);		\
	elif [ -x "$(BYTE)" ]; then				\
		cp -a "$(BYTE)" $(DESTDIR)/$(NAME);		\
	else							\
		echo "Nothing to be installed, aborting.";	\
		exit 2;						\
	fi

$(BYTE): $(NAME).ml
	$(OCAMLC) $(patsubst %,%.cma,$(OCAML_LIBS)) -o $@ $<
$(OPT): $(NAME).ml
	$(OCAMLOPT) $(patsubst %,%.cmxa,$(OCAML_LIBS)) -o $@ $<

clean:
	rm -f ocaml-md5sums ocaml-md5sums.opt *.cm[aiox] *.cmxa *.[ao]

