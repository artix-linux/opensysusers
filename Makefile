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
	BINNAME = systemd-sysusers
else
	BINPROGS = bin/opensysusers
	BINNAME = opensysusers
endif


all: $(BINPROGS) $(INITD)
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man

edit = sed -e "s|@LIBDIR[@]|$(PREFIX)$(LIBDIR)|" \
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

install-shared:
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(BINDIR)
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	$(INSTALL) -m $(BINMODE) $(LIBS) $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man install

install-default-bin:
	$(INSTALL) -m $(BINMODE) $(BINPROGS) $(DESTDIR)$(PREFIX)$(BINDIR)

install-custom-bin:
	$(INSTALL) -m $(BINMODE) $(BINPROGS) $(DESTDIR)$(PREFIX)$(BINDIR)/$(BINNAME)

install_rc:
	$(INSTALL) -d $(DESTDIR)$(SYSCONFDIR)/{init.d,runlevels/boot}
	$(INSTALL) -m $(BINMODE) $(INITD) $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers
	ln -sf $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers $(DESTDIR)$(SYSCONFDIR)/runlevels/boot/

install-tests:
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(CONFDIR)
	$(INSTALL) -m $(CONFMODE) $(CONFFILES) $(DESTDIR)$(PREFIX)$(CONFDIR)

uninstall-shared:
	for lib in ${LIBS}; do rm -f $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers/$$lib; done
	rm -rf --one-file-system $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man uninstall

uninstall-default-bin:
	rm -f $(DESTDIR)$(PREFIX)/$(BINPROGS)

uninstall-custom-bin:
	rm -f $(DESTDIR)$(PREFIX)$(BINDIR)/$(BINNAME)

uninstall-rc:
	rm -f $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers
	rm -f $(DESTDIR)$(SYSCONFDIR)/runlevels/boot/opensysusers

ifeq ($(HAVESYSTEMD),TRUE)
install: install-shared
uninstall: uninstall-shared
ifeq ($(BINNAME),systemd-sysusers)
install: install-default-bin
uninstall: uninstall-default-bin
else
install: install-custom-bin
uninstall: uninstall-custom-bin
endif

ifeq ($(HAVERC),TRUE)
install: install_rc
uninstall: uninstall-rc
endif

else
install: install-shared install-default-bin
uninstall: uninstall-shared uninstall-default-bin

ifeq ($(HAVERC),TRUE)
install: install_rc
uninstall: uninstall-rc
endif

endif

.PHONY: all install install-tests uninstall
