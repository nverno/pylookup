emacs         ?= emacs
wget          ?= wget
python        ?= python
python2       ?= python2

ifeq ($(OS), Windows_NT)
  python      ?= "$(shell cygpath -m $(shell where python | grep -Pi anaconda))"
endif

VER           := $(shell $(python) --version 2>&1 | \
                 grep -o "[0-9].[0-9].[0-9]*" |     \
                 head -n 1)
MAJOR_VERSION  = $(shell $(python) --version 2>&1 | \
                 grep -Po "(?<=Python )[0-9]")

zip           := python-${VER}-docs-html.zip
html_files     = $(zip:.zip=)

url           ?= http://docs.python.org/${MAJOR_VERSION}/archives/${zip}

.PHONY: clean distclean
all: download

download:
	@if [ ! -d $(html_files) ] ; then           \
		echo "Downloading ${url}";          \
		wget ${url};                        \
		unzip ${zip};                       \
	fi
	$(python2) pylookup.py -u $(html_files)
	$(RM) *.zip

clean:
	$(RM) *.zip *~

distclean: clean
	$(RM) -rf *html *autoloads.el *loaddefs.el TAGS *.elc *.db *autoloads.el
