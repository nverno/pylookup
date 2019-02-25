SHELL         = /bin/bash
emacs         ?= emacs
wget          ?= wget
python        ?= python
python2       ?= python2

ifeq ($(OS), Windows_NT)
  python      ?= "$(shell cygpath -m $(shell where python | grep -Pi anaconda))"
endif

VER           := $(shell $(python) --version 2>&1 |             \
                 grep -Po "(?<=[Pp]ython )[0-9].[0-9].[0-9]*" | \
                 head -n 1)
MAJOR_VERSION = $(shell $(python) --version 2>&1 |              \
                 grep -Po "(?<=[Pp]ython )[0-9]")

MINOR_VERSION = $(shell $(python) --version 2>&1 |              \
                 grep -Po "(?<=[Pp]ython [0-9]\\.)[0-9]")

zip           := python-${VER}-docs-html.zip
html_files    = $(zip:.zip=)

url           ?= https://docs.python.org/${MAJOR_VERSION}.${MINOR_VERSION}/archives/${zip}
# python 2
ifeq (${MAJOR_VERSION},2)
  url         ?= https://docs.python.org/${MAJOR_VERSION}/archives/${zip}
endif

.PHONY: clean distclean
all: ${html_files}

${html_files}: ${zip}
	unzip *.zip
	$(python2) pylookup.py -u $(html_files)

.INTERMEDIATE: ${zip}
${zip}:
	@echo "Downloading ${url}"
	wget ${url}

clean:
	$(RM) *.zip *~

distclean: clean
	$(RM) -rf *html *autoloads.el *loaddefs.el TAGS *.elc *.db *autoloads.el
