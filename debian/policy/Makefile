all: html text

html:
	docbook2html ocaml_packaging_policy.xml -o ocaml_packaging_policy.html

text:
	docbook2txt ocaml_packaging_policy.xml
	mv ocaml_packaging_policy.txt ocaml_packaging_policy

clean:
	$(RM) -rf ocaml_packaging_policy.html ocaml_packaging_policy

upload_web: all
	scp -rC ocaml_packaging_policy ocaml_packaging_policy.html alioth.debian.org:/org/alioth.debian.org/chroot/home/groups/pkg-ocaml-maint/htdocs/

.PHONY: html text upload_web
