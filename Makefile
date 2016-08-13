emacs ?= emacs
wget ?= wget
python ?= python

ifeq ($(OS), Windows_NT)
  python="$(shell cygpath -m $(shell where python | grep -Pi anaconda))"
endif

VER := $(shell $(python) --version 2>&1 | grep -o "[0-9].[0-9].[0-9]*" | head -n 1)
MAJOR_VERSION = $(shell $(python) --version 2>&1 | grep -o "Python [0-9]")

zip := python-${VER}-docs-html.zip
html_files = $(zip:.zip=)

url ?= http://docs.python.org/2/archives/${zip}
url2 ?= http://docs.python.org/3/archives/${zip}

ifneq (2,${MAJOR_VERSION})
  url ?= ${url2}
endif

elpa_dir ?= ~/.emacs.d/elpa
auto ?= pylookup-autoloads.el

el = $(filter-out $(auto),$(wildcard *.el))
elc = $(el:.el=.elc)

batch_flags = -batch \
	--eval "(let ((default-directory                   \
                      (expand-file-name \"$(elpa_dir)\"))) \
                  (normal-top-level-add-subdirs-to-load-path))"

auto_flags ?= \
	--eval "(let ((generated-autoload-file                       \
                      (expand-file-name (unmsys--file-name \"$@\"))) \
                      (wd (expand-file-name default-directory))      \
                      (backup-inhibited t)                           \
                      (default-directory                             \
	                (expand-file-name \"$(elpa_dir)\")))         \
                   (normal-top-level-add-subdirs-to-load-path)       \
                   (update-directory-autoloads wd))"

.PHONY: $(auto) clean distclean
all: download compile $(auto)

compile : $(elc)
%.elc : %.el
	$(emacs) $(batch_flags) -f batch-byte-compile $<

$(auto):
	$(emacs) -batch $(auto_flags)

download:
	@if [ ! -d $(html_files) ] ; then  \
		echo "Downloading ${url}"; \
		wget ${url};               \
		unzip ${zip};              \
	fi
	./pylookup.py -u $(html_files)
	$(RM) *.zip

TAGS: $(el)
	$(RM) $@
	touch $@
	ls $(el) | xargs etags -a -o $@

clean:
	$(RM) *.zip *~

distclean: clean
	$(RM) -rf *html *autoloads.el *loaddefs.el TAGS *.elc *.db *autoloads.el
