prefix=/usr/local
exec_prefix=${prefix}

#finds the site-packages dir that matches the selected prefix.
#pkgdir=`python -c 'import sys,re; x=filter(lambda x: re.match("$(prefix).*site-packages",x),sys.path); x.sort(lambda x,y: cmp(len(x),len(y))); print x[0]'`

#finds the site-packages dir that matches the selected prefix, or if none do, falls back to wherever it can find one..
pkgdir=`python -c 'import sys,re; x=filter(lambda x: re.match("$(prefix).*site-packages",x),sys.path); y=filter(lambda y: re.search("site-packages",y),sys.path); x.sort(lambda x,y: cmp(len(x),len(y))); y.sort(lambda x,y: cmp(len(x),len(y))); x.extend(y); print x[0]'`
#nice little expression, huh? ;)

bindir=${exec_prefix}/bin
mandir=${prefix}/man
install=/usr/bin/install -c
user=root
group=root

foo:
	@echo 'to install cfv, type make install or install-wrapper.'
	@echo "manpage will be installed to: $(mandir)/man1"
	@echo ""
	@echo '"make install" will install like a standard script in'
	@echo "$(bindir)"
	@echo ""
	@echo '"make install-wrapper" will install a byte-compiled version in'
	@echo "$(pkgdir)"
	@echo 'with a small wrapper script in $(bindir)'
	@echo 'this allows for faster loading time since python does not need'
	@echo 'to parse the entire script every load.'
	@echo ""
	@echo 'You may edit the Makefile if you want to install somewhere else.'
	@echo ""
	@echo "Note that this method does not change how fast cfv actually runs,"
	@echo "merely the time it takes from when you hit enter till it actually"
	@echo "starts doing something.  For processing lots of files, this amount"
	@echo "of time will be inconsequential."


cfv.wrapper:
	python -c 'import string,os; py=filter(lambda x: os.path.isfile(x),map(lambda x: os.path.join(x,"python"),string.split(os.environ["PATH"],":"))); py.append(" /usr/bin/env python"); open("cfv.wrapper","w").write("#!%s\nimport cfv\n"%py[0])'

install-wrapper-only: cfv.wrapper install_man
	$(install) -o $(user) -g $(group) -m 0644 cfv $(DESTDIR)$(pkgdir)/cfv.py
	$(install) -o $(user) -g $(group) -m 0755 cfv.wrapper $(DESTDIR)$(bindir)/cfv

install-wrapper: install-wrapper-only
	python -c "import py_compile; py_compile.compile('$(DESTDIR)$(pkgdir)/cfv.py')" 
	python -O -c "import py_compile; py_compile.compile('$(DESTDIR)$(pkgdir)/cfv.py')" 

install: install_man
	$(install) -o $(user) -g $(group) -m 0755 cfv $(DESTDIR)$(bindir)

install_man:
	$(install) -o $(user) -g $(group) -m 0644 cfv.1 $(DESTDIR)$(mandir)/man1

clean:
	-rm *.py[co] cfv.wrapper

distclean: clean
	-rm -r test/test.log `find . -regex '^.*~$$' -o -name CVS`
