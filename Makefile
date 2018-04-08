LIBS = common.sh
CONFFILES = test/*
PREFIX = /usr/local
BINDIR = /bin
LIBDIR = /lib
MANDIR = /share/man
DOCDIR = /share/doc/opensysusers
CONFDIR = /run/sysusers.d
BINMODE = 0755
CONFMODE = 0644
DOCMODE = 0644
INSTALL = install
MAKE = make
SYSTEMDCOMPAT = TRUE
ifeq ($(SYSTEMDCOMPAT),TRUE)
	BINPROGS = systemd-sysusers
else
	BINPROGS = opensysusers
endif

all:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man
	sed -e "s|@BINFILE@|$(BINPROGS)|" openrc/opensysusers.initd.in | tee openrc/opensysusers.initd

clean:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man clean

install:
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(BINDIR)
	$(INSTALL) -m $(BINMODE) $(BINPROGS) $(DESTDIR)$(PREFIX)$(BINDIR)
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	$(INSTALL) -m $(BINMODE) $(LIBS) $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	for prog in ${BINPROGS}; do sed -e "s|@LIBDIR@|$(PREFIX)$(LIBDIR)|" -i $(DESTDIR)$(PREFIX)$(BINDIR)/$$prog; done
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man install

install-tests:
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(CONFDIR)
	$(INSTALL) -m $(CONFMODE) $(CONFFILES) $(DESTDIR)$(PREFIX)$(CONFDIR)

uninstall:
	for prog in ${BINPROGS}; do rm -f $(DESTDIR)$(PREFIX)$(BINDIR)/$$prog; done
	for lib in ${LIBS}; do rm -f $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers/$$lib; done
	rm -rf --one-file-system $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man uninstall

.PHONY: all install install-tests uninstal
