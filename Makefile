%.html: %.xml
	xsltproc --nonet --output $@ \
	/usr/share/sgml/docbook/stylesheet/xsl/nwalsh/html/docbook.xsl \
	$^ 

all: ocaml_packaging_policy.html 

clean:
	$(RM) ocaml_packaging_policy.html
