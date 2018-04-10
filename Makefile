VERSION = 0.4.6
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

HAVESYSTEMD = yes
HAVERC = yes
HAVEMAN = no

LIBS = lib/common.sh
INITD = openrc/opensysusers.initd

ifeq ($(HAVESYSTEMD),yes)
	BINPROGS = bin/systemd-sysusers
	BINNAME = systemd-sysusers
else
	BINPROGS = bin/opensysusers
	BINNAME = opensysusers
endif


all: $(BINPROGS)
ifeq ($(HAVERC),yes)
all: $(INITD)
endif
ifeq ($(HAVEMAN),yes)
all:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man
endif


EDIT = sed -e "s|@LIBDIR[@]|$(PREFIX)$(LIBDIR)|" \
	-e "s|@BINNAME[@]|$(BINNAME)|g" \
	-e "s|@VERSION[@]|$(VERSION)|g"

RM = rm -f
M4 = m4 -P
CHMODAW = chmod a-w
CHMODX = chmod +x

%: %.in Makefile
	@echo "GEN $@"
	@$(RM) "$@"
	@$(M4) $@.in | $(EDIT) >$@
	@$(CHMODAW) "$@"
	@$(CHMODX) "$@"

clean-bin:
	$(RM) $(BINPROGS)

clean-rc:
	$(RM) $(INITD)

clean-man:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man clean

clean: clean-bin
ifeq ($(HAVERC),yes)
clean: clean-rc
endif
ifeq ($(HAVEMAN),yes)
clean: clean-man
endif

install-shared:
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(BINDIR)
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers
	$(INSTALL) -m $(BINMODE) $(LIBS) $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers

install-default-bin:
	$(INSTALL) -m $(BINMODE) $(BINPROGS) $(DESTDIR)$(PREFIX)$(BINDIR)

install-custom-bin:
	$(INSTALL) -m $(BINMODE) $(BINPROGS) $(DESTDIR)$(PREFIX)$(BINDIR)/$(BINNAME)

install_rc:
	$(INSTALL) -d $(DESTDIR)$(SYSCONFDIR)/{init.d,runlevels/boot}
	$(INSTALL) -m $(BINMODE) $(INITD) $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers
	ln -sf $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers $(DESTDIR)$(SYSCONFDIR)/runlevels/boot/

install-man:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man install

install-tests:
	$(INSTALL) -d $(DESTDIR)$(PREFIX)$(CONFDIR)
	$(INSTALL) -m $(CONFMODE) $(CONFFILES) $(DESTDIR)$(PREFIX)$(CONFDIR)

uninstall-shared:
	for lib in $(notdir ${LIBS}); do $(RM) $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers/$$lib; done
	$(RM)r --one-file-system $(DESTDIR)$(PREFIX)$(LIBDIR)/opensysusers

uninstall-default-bin:
	$(RM) $(DESTDIR)$(PREFIX)$(BINDIR)/$(notdir $(BINPROGS))

uninstall-custom-bin:
	$(RM) $(DESTDIR)$(PREFIX)$(BINDIR)/$(BINNAME)

uninstall-rc:
	$(RM) $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers
	$(RM) $(DESTDIR)$(SYSCONFDIR)/runlevels/boot/opensysusers

uninstall-man:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(DOCMODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) -C man uninstall

ifeq ($(HAVESYSTEMD),yes)
install: install-shared
uninstall: uninstall-shared
ifeq ($(HAVEMAN),yes)
install: install-man
uninstall: uninstall-man
endif
ifeq ($(BINNAME),systemd-sysusers)
install: install-default-bin
uninstall: uninstall-default-bin
else
install: install-custom-bin
uninstall: uninstall-custom-bin
endif

ifeq ($(HAVERC),yes)
install: install_rc
uninstall: uninstall-rc
endif

else
install: install-shared install-default-bin
uninstall: uninstall-shared uninstall-default-bin
ifeq ($(HAVEMAN),yes)
install: install-man
uninstall: uninstall-man
endif
ifeq ($(HAVERC),yes)
install: install_rc
uninstall: uninstall-rc
endif

endif

.PHONY: all install install-tests uninstall
