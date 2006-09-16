all: html text

html: ocaml_packaging_policy.html/index.html
text: ocaml_packaging_policy.txt

ocaml_packaging_policy.html/index.html: ocaml_packaging_policy.xml *.xml
	docbook2html $< -o $(dir $@)
ocaml_packaging_policy.txt: ocaml_packaging_policy.xml *.xml
	docbook2txt $<

clean:
	$(RM) -rf ocaml_packaging_policy.html/ ocaml_packaging_policy.txt

upload_web: all
	scp -rC ocaml_packaging_policy ocaml_packaging_policy.html alioth.debian.org:/org/alioth.debian.org/chroot/home/groups/pkg-ocaml-maint/htdocs/

.PHONY: html text upload_web
