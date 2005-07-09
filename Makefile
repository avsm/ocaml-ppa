
# DEBHELPER_VERSION := $(shell grep-available -X -F Package -s Version debhelper | cut -f 2 -d ' ')
DEBHELPER_VERSION = 4.9.3
OCAML_VERSION = 3.08.3
OCAML_LIB_DIR = /usr/lib/ocaml/$(OCAML_VERSION)
DEBHELPER_DSC = debhelper_$(DEBHELPER_VERSION).dsc
NEW_DEBHELPER_VERSION = $(DEBHELPER_VERSION)+dh_ocaml
DEBHELPER_DIR = debhelper-$(DEBHELPER_VERSION)
NEW_DEBHELPER_DIR = debhelper-$(NEW_DEBHELPER_VERSION)
FED_SUMS = ocaml-nox.md5sums ocaml.md5sums ocaml-compiler-libs.md5sums
OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAML_LIBS = unix str

all: ocaml-md5sums
opt: ocaml-md5sums.opt
world: all opt

ocaml-md5sums: ocaml-md5sums.ml
	$(OCAMLC) $(patsubst %,%.cma,$(OCAML_LIBS)) -o $@ $<
ocaml-md5sums.opt: ocaml-md5sums.ml
	$(OCAMLOPT) $(patsubst %,%.cmxa,$(OCAML_LIBS)) -o $@ $<

$(DEBHELPER_DSC):
	apt-get -d source debhelper

debhelper: $(SCRIPTS) $(DEBHELPER_DSC)
	rm -rf $(DEBHELPER_DIR)/ $(NEW_DEBHELPER_DIR)/
	dpkg-source -x debhelper_$(DEBHELPER_VERSION).dsc
	cp dh_ocaml $(DEBHELPER_DIR)/
	cp $(SCRIPTS) $(DEBHELPER_DIR)/autoscripts/
	cd $(DEBHELPER_DIR)	\
		&& dch --newversion $(NEW_DEBHELPER_VERSION) "added dh_ocaml"	\
		&& debuild binary

feeding: $(FED_SUMS)
%.md5sums: ocaml-md5sums
	dpkg -L $* \
	| grep '.cm[ao]' \
	| grep -v ^$(OCAML_LIB_DIR)/ocamldoc/ \
	| grep -v ^$(OCAML_LIB_DIR)/camlp4/ \
	| ./ocaml-md5sums compute \
		--package $*-$(OCAML_VERSION) \
		--runtime $(patsubst ocaml%, ocaml-base%, $*)-$(OCAML_VERSION) \
	| sort -k 2 \
	> $@
ocaml-compiler-libs.md5sums: ocaml-md5sums ocaml-nox.md5sums
	dpkg -L ocaml-compiler-libs \
	| grep '.cm[ao]' \
	| ./ocaml-md5sums compute \
	 --package ocaml-compiler-libs-$(OCAML_VERSION) \
	| sort -k 2 \
	> $@

%: %.in
	wml -p 1-3 $< > $@

clean:
	rm -f ocaml-md5sums ocaml-md5sums.opt $(FED_SUMS)
	rm -f *.cm[aiox] *.cmxa *.[ao]

