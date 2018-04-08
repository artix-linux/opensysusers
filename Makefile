binprogs = sysusers systemd-sysusers
libs = common.sh
conffiles = test/*
PREFIX = /usr/local
BINDIR = /bin
LIBDIR = /lib
MANDIR = /share/man
DOCDIR = /share/doc/opensysusers
CONFDIR = /run/sysusers.d
binmode = 0755
confmode = 0644
docmode = 0644
install = install
make = make

all:
	$(make) -C man

clean:
	$(make) install=$(install) docmode=$(docmode) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man clean

install:
	$(install) -d $(DESTDIR)$(PREFIX)$(BINDIR)
	$(install) -m $(binmode) $(binprogs) $(DESTDIR)$(PREFIX)$(BINDIR)
	$(install) -d $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	$(install) -m $(binmode) $(libs) $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	for prog in ${binprogs}; do sed -e "s|@BINDIR@|$(BINDIR)|" -i $(DESTDIR)$(PREFIX)$(BINDIR)/$$prog; done
	for prog in ${binprogs}; do sed -e "s|@LIBDIR@|$(LIBDIR)|" -i $(DESTDIR)$(PREFIX)$(BINDIR)/$$prog; done
	$(make) install=$(install) docmode=$(docmode) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man install

install-tests:
	$(install) -d $(DESTDIR)$(PREFIX)$(CONFDIR)
	$(install) -m $(confmode) $(conffiles) $(DESTDIR)$(PREFIX)$(CONFDIR)

uninstall:
	for prog in ${binprogs}; do rm -f $(DESTDIR)$(PREFIX)$(BINDIR)/$$prog; done
	for lib in ${libs}; do rm -f $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers/$$lib; done
	rm -rf --one-file-system $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	$(make) install=$(install) docmode=$(docmode) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man uninstall

.PHONY: all install install-tests uninstall
