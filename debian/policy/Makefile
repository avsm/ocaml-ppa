all: html text

html:
	docbook2html ocaml_packaging_policy.xml -o packaging-policy-html

text:
	docbook2txt ocaml_packaging_policy.xml

clean:
	$(RM) -rf packaging-policy-html ocaml_packaging_policy.txt

.PHONY: html text
