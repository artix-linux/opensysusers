VERSION = 0.4.8
SYSCONFDIR = /etc
PREFIX ?= /usr
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib
MANDIR = $(PREFIX)/share/man
DOCDIR = $(PREFIX)/share/doc/opensysusers
TESTDIR = /run/sysusers.d
BINMODE = 0755
MODE = 0644
INSTALL = install
MAKE = make

LIBS = lib/common.sh
INITD = openrc/opensysusers.initd

BINPROGS = bin/sysusers
BINNAME = sysusers

TESTFILES = $(wildcard test/*.conf)

all: $(BINPROGS) $(INITD)
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(MODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) DESTDIR=$(DESTDIR) -C man

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

clean: clean-bin clean-openrc clean-man

install-shared:
	$(INSTALL) -d $(DESTDIR)$(LIBDIR)/opensysusers
	$(INSTALL) -m $(BINMODE) $(LIBS) $(DESTDIR)$(LIBDIR)/opensysusers

install-default-bin:
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	$(INSTALL) -m $(BINMODE) $(BINPROGS) $(DESTDIR)$(BINDIR)

install-openrc:
	$(INSTALL) -d $(DESTDIR)$(SYSCONFDIR)/init.d
	$(INSTALL) -m $(BINMODE) $(INITD) $(DESTDIR)$(SYSCONFDIR)/init.d/opensysusers

install-man:
	+$(MAKE) INSTALL=$(INSTALL) DOCMODE=$(MODE) MANDIR=$(MANDIR) DOCDIR=$(DOCDIR) DESTDIR=$(DESTDIR) -C man install

install-tests:
	$(INSTALL) -d $(DESTDIR)$(TESTDIR)
	$(INSTALL) -m $(MODE) $(TESTFILES) $(DESTDIR)$(TESTDIR)

install: install-shared install-default-bin install-man install-openrc

.PHONY: all install install-custom-bin install-default-bin install-man install-openrc install-shared install-tests clean clean-bin clean-man clean-openrc
