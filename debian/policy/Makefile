all: html text

html:
	docbook2html ocaml_packaging_policy.xml -o ocaml_packaging_policy.html

text:
	docbook2txt ocaml_packaging_policy.xml
	mv ocaml_packaging_policy.txt ocaml_packaging_policy

clean:
	$(RM) -rf ocaml_packaging_policy.html ocaml_packaging_policy

.PHONY: html text
