binprogs = sysusers
conffiles = test/*
bindir = /bin
confdir = /run/sysusers.d
binmode = 0755
confmode = 0644
install = install

all:

install:
	$(install) -d $(DESTDIR)$(bindir)
	$(install) -m $(binmode) $(binprogs) $(DESTDIR)$(bindir)

install-tests:
	$(install) -d $(DESTDIR)$(confdir)
	$(install) -m $(confmode) $(conffiles) $(DESTDIR)$(confdir)

.PHONY: all install install-tests
