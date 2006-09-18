all: dh_ocaml.1

install: all
	mkdir -p $(DESTDIR)/usr/bin
	cp dh_ocaml $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/usr/share/man/man1
	cp dh_ocaml.1 $(DESTDIR)/usr/share/man/man1/

clean:
	rm -f dh_ocaml.1

dh_ocaml.1:
	pod2man dh_ocaml > $@
