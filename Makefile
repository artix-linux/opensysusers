CONFFILES = test/*
SYSCONFDIR = /etc
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

HAVESYSTEMD = TRUE
HAVERC = TRUE

LIBS = lib/common.sh
INITD = openrc/opensysusers.initd

ifeq ($(HAVESYSTEMD),TRUE)
	BINPROGS = bin/systemd-sysusers
	BINNAME = 'systemd-sysusers'
else
	BINPROGS = bin/opensysusers
	BINNAME = 'opensysusers'
endif

all:	$(BINPROGS) $(INITD)
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man

edit = sed -e "s|@LIBDIR[@]|$(DESTDIR)$(PREFIX)$(LIBDIR)|" \
	-e "s|@BINNAME[@]|$(BINNAME)|g"

%: %.in Makefile
	@echo "GEN $@"
	@$(RM) "$@"
	@m4 -P $@.in | $(edit) >$@
	@chmod a-w "$@"
	@chmod +x "$@"

clean:
	rm -f $(BINPROGS) ${INITD}
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man clean

install:
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(BINDIR)
	$(INSTALL) -m $(BINMODE) $(BINPROGS) $(DESTDIR)$(PREFIX)$(BINDIR)
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	$(INSTALL) -m $(BINMODE) $(LIBS) $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man install

	ifeq ($(HAVESYSTEMD),TRUE)
		[ "${BINNAME}" != 'systemd-sysusers' ]  && mv $(DESTDIR)$(PREFIX)$(BINDIR)/$(BINPROGS) $(DESTDIR)$(PREFIX)$(BINDIR)/$(BINNAME)
	endif

	ifeq ($(HAVERC),TRUE)
		$(INSTALL) -d $(DESTDIR)$(SYSCONFDIR)/{init.d,runlevels/boot}
		$(INSTALL) -m $(BINMODE) $(INITD) $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers
		ln -sf $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers $(DESTDIR)$(SYSCONFDIR)/runlevels/boot/
	endif

install-tests:
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(CONFDIR)
	$(INSTALL) -m $(CONFMODE) $(CONFFILES) $(DESTDIR)$(PREFIX)$(CONFDIR)

uninstall:
	for prog in ${BINPROGS}; do rm -f $(DESTDIR)$(PREFIX)$(BINDIR)/$$prog; done
	for lib in ${LIBS}; do rm -f $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers/$$lib; done
	rm -rf --one-file-system $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man uninstall

	ifeq ($(HAVESYSTEMD),TRUE)
		[ "${BINNAME}" != 'systemd-sysusers' ] && rm -f $(DESTDIR)$(PREFIX)$(BINDIR)/$(BINNAME)
	endif

	ifeq ($(HAVERC),TRUE)
		for svc in ${INITD}; do rm -f $(DESTDIR)$(SYSCONFDIR)/init.d/$$lib; done
	endif

.PHONY: all install install-tests uninstall
