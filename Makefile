VERSION = 0.4.7
SYSCONFDIR = /etc
ifdef PREFIX
PREFIX = /usr/local
endif
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib
MANDIR = $(PREFIX)/share/man
DOCDIR = $(PREFIX)/share/doc/opensysusers
TESTDIR = /run/sysusers.d
BINMODE = 0755
MODE = 0644
INSTALL = install
MAKE = make

HAVESYSTEMD = yes
HAVEOPENRC = no
HAVEMAN = yes

LIBS = lib/common.sh
INITD = openrc/opensysusers.initd

ifeq ($(HAVESYSTEMD),yes)
	BINPROGS = bin/sysusers
	BINNAME = sysusers
else
	BINPROGS = bin/opensysusers
	BINNAME = opensysusers
endif

TESTFILES = $(wildcard test/*.conf)

all: $(BINPROGS)
ifeq ($(HAVEOPENRC),yes)
all: $(INITD)
endif
ifeq ($(HAVEMAN),yes)
all:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(MODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) DESTDIR=$(DESTDIR) -C man
endif


EDIT = sed -e "s|@LIBDIR[@]|$(LIBDIR)|" \
	-e "s|@BINNAME[@]|$(BINNAME)|g" \
	-e "s|@VERSION[@]|$(VERSION)|"

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

clean-openrc:
	$(RM) $(INITD)

clean-man:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(MODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) DESTDIR=$(DESTDIR) -C man clean

clean: clean-bin
ifeq ($(HAVEOPENRC),yes)
clean: clean-openrc
endif
ifeq ($(HAVEMAN),yes)
clean: clean-man
endif

install-shared:
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	$(INSTALL) -d $(DESTDIR)$(LIBDIR)/opensysusers
	$(INSTALL) -m $(BINMODE) $(LIBS) $(DESTDIR)$(LIBDIR)/opensysusers

install-default-bin:
	$(INSTALL) -m $(BINMODE) $(BINPROGS) $(DESTDIR)$(BINDIR)

install-custom-bin:
	$(INSTALL) -m $(BINMODE) $(BINPROGS) $(DESTDIR)$(BINDIR)/$(BINNAME)

install-openrc:
	$(INSTALL) -d $(DESTDIR)$(SYSCONFDIR)/{init.d,runlevels/boot}
	$(INSTALL) -m $(BINMODE) $(INITD) $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers
	ln -sf $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers $(DESTDIR)$(SYSCONFDIR)/runlevels/boot/

install-man:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(MODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) DESTDIR=$(DESTDIR) -C man install

install-tests:
	$(INSTALL) -d $(DESTDIR)$(TESTDIR)
	$(INSTALL) -m $(MODE) $(TESTFILES) $(DESTDIR)$(TESTDIR)

uninstall-shared:
	for lib in $(notdir ${LIBS}); do $(RM) $(DESTDIR)$(LIBDIR)/opensysusers/$$lib; done
	$(RM)r --one-file-system $(DESTDIR)$(LIBDIR)/opensysusers

uninstall-default-bin:
	$(RM) $(DESTDIR)$(BINDIR)/$(notdir $(BINPROGS))

uninstall-custom-bin:
	$(RM) $(DESTDIR)$(BINDIR)/$(BINNAME)

uninstall-openrc:
	$(RM) $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers
	$(RM) $(DESTDIR)$(SYSCONFDIR)/runlevels/boot/opensysusers

uninstall-man:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(MODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) DESTDIR=$(DESTDIR) -C man uninstall

ifeq ($(HAVESYSTEMD),yes)
install: install-shared
uninstall: uninstall-shared
ifeq ($(HAVEMAN),yes)
install: install-man
uninstall: uninstall-man
endif
ifeq ($(BINNAME),sysusers)
install: install-default-bin
uninstall: uninstall-default-bin
else
install: install-custom-bin
uninstall: uninstall-custom-bin
endif

ifeq ($(HAVEOPENRC),yes)
install: install-openrc
uninstall: uninstall-openrc
endif

else
install: install-shared install-default-bin
uninstall: uninstall-shared uninstall-default-bin
ifeq ($(HAVEMAN),yes)
install: install-man
uninstall: uninstall-man
endif
ifeq ($(HAVEOPENRC),yes)
install: install-openrc
uninstall: uninstall-openrc
endif

endif

.PHONY: all install install-custom-bin install-default-bin install-man install-openrc install-shared install-tests uninstall uninstall-custom-bin uninstall-default-bin uninstall-man uninstall-openrc uninstall-shared clean clean-bin clean-man clean-openrc
