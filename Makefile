emacs ?= emacs
wget ?= wget
python ?= python

ifeq ($(OS), Windows_NT)
  python ?= "$(shell cygpath -m $(shell where python | grep -Pi anaconda))"
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

.PHONY: clean distclean
all: download

download:
	@if [ ! -d $(html_files) ] ; then  \
		echo "Downloading ${url}"; \
		wget ${url};               \
		unzip ${zip};              \
	fi
	$(python) pylookup.py -u $(html_files)
	$(RM) *.zip

clean:
	$(RM) *.zip *~

distclean: clean
	$(RM) -rf *html *autoloads.el *loaddefs.el TAGS *.elc *.db *autoloads.el
