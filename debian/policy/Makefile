NULL =
INSTALL_STUFF =				\
	ocaml_packaging_policy.html/	\
	ocaml_packaging_policy.txt	\
	$(NULL)

all: html text

# to be used on alioth for updating policy linked by pkg-ocaml-maint home page
install: all
	cp -r $(INSTALL_STUFF) ~/pkg-ocaml-maint/htdocs/

html: ocaml_packaging_policy.html/index.html
text: ocaml_packaging_policy.txt

ocaml_packaging_policy.html/index.html: ocaml_packaging_policy.xml *.xml
	docbook2html $< -o $(dir $@)
ocaml_packaging_policy.txt: ocaml_packaging_policy.xml *.xml
	docbook2txt $<

clean:
	$(RM) -rf ocaml_packaging_policy.html/ ocaml_packaging_policy.txt

upload_web: all
	scp -rC ocaml_packaging_policy.txt ocaml_packaging_policy.html alioth.debian.org:/org/alioth.debian.org/chroot/home/groups/pkg-ocaml-maint/htdocs/
	ssh alioth.debian.org "chmod g+w /org/alioth.debian.org/chroot/home/groups/pkg-ocaml-maint/htdocs/ocaml_packaging_policy.txt /org/alioth.debian.org/chroot/home/groups/pkg-ocaml-maint/htdocs/ocaml_packaging_policy.html/*"

.PHONY: html text upload_web
