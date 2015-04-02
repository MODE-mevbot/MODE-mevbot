
#
# Note: Due to MELPA distributing directly from github source version
# needs to be embedded in files as is without proprocessing.
#
# Version string is present in:
# - Makefile
# - haskell-mode.el
# - haskell-mode.texi
# - haskell-mode-pkg.el (used for marmelade)
#
# We should have a script that changes it everywhere it is needed and
# syncs it with current git tag.
#
VERSION = 13.12

INSTALL_INFO = install-info
EMACS = emacs
EFLAGS = --eval "(add-to-list 'load-path (expand-file-name \"tests/compat\") 'append)" \
         --eval "(when (< emacs-major-version 24) \
                    (setq byte-compile-warnings '(not cl-functions)))" \
         --eval '(setq byte-compile-error-on-warn t)'

BATCH = $(EMACS) $(EFLAGS) --batch -Q -L .

ELFILES = \
	ghc-core.el \
	ghci-script-mode.el \
	highlight-uses-mode.el \
	haskell-align-imports.el \
	haskell-bot.el \
	haskell-cabal.el \
	haskell-checkers.el \
	haskell-collapse.el \
	haskell-modules.el \
	haskell-sandbox.el \
	haskell-commands.el \
	haskell-compat.el \
	haskell-compile.el \
	haskell-complete-module.el \
	haskell-customize.el \
	haskell-debug.el \
	haskell-decl-scan.el \
	haskell-doc.el \
	haskell.el \
	haskell-font-lock.el \
	haskell-indentation.el \
	haskell-indent.el \
	haskell-interactive-mode.el \
	haskell-load.el \
	haskell-menu.el \
	haskell-mode.el \
	haskell-move-nested.el \
	haskell-navigate-imports.el \
	haskell-package.el \
	haskell-presentation-mode.el \
	haskell-process.el \
	haskell-repl.el \
	haskell-session.el \
	haskell-show.el \
	haskell-simple-indent.el \
	haskell-sort-imports.el \
	haskell-string.el \
	haskell-unicode-input-method.el \
	haskell-utils.el \
	haskell-yas.el \
	inf-haskell.el

ELCFILES = $(ELFILES:.el=.elc)
AUTOLOADS = haskell-mode-autoloads.el

PKG_DIST_FILES = $(ELFILES) logo.svg NEWS haskell-mode.info dir
PKG_TAR = haskell-mode-$(VERSION).tar
ELCHECKS=$(patsubst %.el,check-%, $(ELFILES))

%.elc: %.el
	@$(BATCH) -f batch-byte-compile $*.el

.PHONY: all compile info clean check $(ELCHECKS) elpa package

all: compile $(AUTOLOADS) info

compile: .make/compile

.make :
	@mkdir .make

.make/compile: $(ELFILES) | .make
	@$(RM) $(patsubst %.el,%.elc,$?)
	$(BATCH) -f batch-byte-compile $?
	@touch $@

$(ELCHECKS): check-%: %.el %.elc
	@if [ -f "$(<:%.el=tests/%-tests.el)" ]; then \
		$(BATCH) -l "$(<:%.el=tests/%-tests.el)" -f ert-run-tests-batch-and-exit; \
	fi
	@echo "--"

check: .make/check

.make/check: $(wildcard tests/*-tests.el) | compile .make
	$(BATCH) $(patsubst %,-l %,$?) -f ert-run-tests-batch-and-exit
	@touch $@
	@echo "checks passed!"

clean:
	$(RM) $(ELCFILES) $(AUTOLOADS) $(AUTOLOADS:.el=.elc) $(PKG_TAR) haskell-mode.info dir

info: haskell-mode.info dir

dir: haskell-mode.info
	$(INSTALL_INFO) --dir=$@ $<

haskell-mode.info: haskell-mode.texi
	# Check if chapter order is same as node order
	@sed -n -e '/@chapter/ s/@code{\(.*\)}/\1/' \
                -e 's/@chapter \(.*\)$$/* \1::/p' \
                -e 's/@unnumbered \(.*\)$$/* \1::/p' \
               haskell-mode.texi > haskell-mode-menu-order.txt
	@sed -e '1,/@menu/ d' \
            -e '/end menu/,$$ d' \
            haskell-mode.texi > haskell-mode-content-order.txt
	diff -C 1 haskell-mode-menu-order.txt haskell-mode-content-order.txt
	@rm haskell-mode-menu-order.txt haskell-mode-content-order.txt

	# Processing proper
	$(MAKEINFO) $(MAKEINFO_FLAGS) -o $@ $<

haskell-mode.html: haskell-mode.texi
	$(MAKEINFO) $(MAKEINFO_FLAGS) --html --no-split -o $@ $<

# Generate ELPA-compatible package
package: $(PKG_TAR)
elpa: $(PKG_TAR)

$(PKG_TAR): $(PKG_DIST_FILES) haskell-mode-pkg.el
	rm -rf haskell-mode-$(VERSION)
	mkdir haskell-mode-$(VERSION)
	cp $(PKG_DIST_FILES) haskell-mode-$(VERSION)/

	tar cvf $@ haskell-mode-$(VERSION)
	rm -rf haskell-mode-$(VERSION)
	@echo
	@echo "Created ELPA compatible distribution package '$@' from $(VERSION)"

$(AUTOLOADS): $(ELFILES) haskell-mode.elc
	$(BATCH) \
		--eval '(setq make-backup-files nil)' \
		--eval '(setq generated-autoload-file "$(CURDIR)/$@")' \
		-f batch-update-autoloads "."
