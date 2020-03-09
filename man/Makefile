manfiles5 = sysusers.d.5
manfiles8 = systemd-sysusers.8 systemd-sysusers.service.8
docfiles = sysusers.d.html systemd-sysusers.html

xsltargs = --nonet \
	--xinclude \
	--maxdepth 9000 \
	--stringparam man.output.quietly 1 \
	--stringparam funcsysnopsis.style ansi \
	--stringparam man.authors.section.enabled 0 \
	--stringparam man.copyright.section.enabled 0 \
	--stringparam systemd.version 238.51

all:
	xsltproc $(xsltargs) custom-man.xsl systemd-sysusers.xml
	xsltproc $(xsltargs) custom-html.xsl systemd-sysusers.xml > systemd-sysusers.html
	xsltproc $(xsltargs) custom-man.xsl sysusers.d.xml
	xsltproc $(xsltargs) custom-html.xsl sysusers.d.xml > sysusers.d.html

clean:
	rm $(manfiles5)
	rm $(manfiles8)
	rm $(docfiles)

install:
	$(INSTALL) -d $(DESTDIR)$(MANDIR)/man5 $(DESTDIR)$(MANDIR)/man8
	$(INSTALL) -m $(DOCMODE) $(manfiles5) $(DESTDIR)$(MANDIR)/man5
	$(INSTALL) -m $(DOCMODE) $(manfiles8) $(DESTDIR)$(MANDIR)/man8
	$(INSTALL) -d $(DESTDIR)$(DOCDIR)
	$(INSTALL) -m $(DOCMODE) $(docfiles) $(DESTDIR)$(DOCDIR)

uninstall:
	for man in ${manfiles5}; do rm -f $(DESTDIR)$(MANDIR)/man5/$$man; done
	for man in ${manfiles8}; do rm -f $(DESTDIR)$(MANDIR)/man8/$$man; done
	for doc in ${docfiles}; do rm -f $(DESTDIR)$(DOCDIR)/$$doc; done
	rm -rf --one-file-system $(DESTDIR)$(DOCDIR)

.PHONY: all install clean
