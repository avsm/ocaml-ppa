
SCRIPTS = postinst-ocaml postrm-ocaml
# DEBHELPER_VERSION := $(shell grep-available -X -F Package -s Version debhelper | cut -f 2 -d ' ')
DEBHELPER_VERSION = 4.2.32
DEBHELPER_DSC = debhelper_$(DEBHELPER_VERSION).dsc
NEW_DEBHELPER_VERSION = $(DEBHELPER_VERSION)+dh_ocaml
DEBHELPER_DIR = debhelper-$(DEBHELPER_VERSION)
NEW_DEBHELPER_DIR = debhelper-$(NEW_DEBHELPER_VERSION)

# all: ocaml-md5sums $(SCRIPTS) debhelper
all: ocaml-md5sums $(SCRIPTS)

ocaml-md5sums: ocaml-md5sums.ml
	ocamlfind ocamlc -package str,unix -linkpkg -o $@ $<

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

%: %.in
	wml -p 1-3 $< > $@

clean:
	rm -f $(TARGETS)

