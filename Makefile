SYSCONFDIR = /etc
PREFIX ?= /usr/local
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

INITD = opensysusers.initd

BASIC = basic.conf

ifeq ($(HAVESYSTEMD),yes)
	BINNAME = sysusers
else
	BINNAME = opensysusers
endif

TESTFILES = $(wildcard test/*.conf)

all: sysusers
ifeq ($(HAVEOPENRC),yes)
all: $(INITD)
endif
ifeq ($(HAVEMAN),yes)
all:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(MODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) DESTDIR=$(DESTDIR) -C man
endif

EDIT = sed "s|@BINNAME[@]|$(BINNAME)|"

RM = rm -f
CHMOD = chmod $(BINMODE)

opensysusers: sysusers
	$(INSTALL) $< $@

$(INITD): $(INITD).in
	@echo "GEN $@"
	@$(RM) "$@"
	@$(EDIT) $< >"$@"
	@$(CHMOD) "$@"

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
	$(INSTALL) -Dm $(MODE) $(BASIC) $(DESTDIR)$(LIBDIR)/sysusers.d/$(BASIC)

install-default-bin: sysusers
	$(INSTALL) -Dm $(BINMODE) sysusers $(DESTDIR)$(BINDIR)/$(BINNAME)

install-custom-bin: sysusers
	$(INSTALL) -Dm $(BINMODE) sysusers $(DESTDIR)$(BINDIR)/$(BINNAME)

install-openrc: $(INITD)
	$(INSTALL) -Dm $(BINMODE) $(INITD) $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers

install-man:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(MODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) DESTDIR=$(DESTDIR) -C man install

install-tests:
	$(INSTALL) -Dm $(MODE) $(TESTFILES) $(DESTDIR)$(TESTDIR)/

uninstall-shared:
	$(RM) $(DESTDIR)$(LIBDIR)/sysusers.d/$(BASIC)

uninstall-default-bin:
	$(RM) $(DESTDIR)$(BINDIR)/$(BINNAME)

uninstall-custom-bin:
	$(RM) $(DESTDIR)$(BINDIR)/$(BINNAME)

uninstall-openrc:
	$(RM) $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers

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
