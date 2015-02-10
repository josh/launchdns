CC = cc
CFLAGS = -Wall
INSTALL = /usr/bin/install
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
BATS = test/bats/bin/bats
CONFIG = config.h
SOURCES = main.c
EXECUTABLE = launchdns

all: $(EXECUTABLE)

$(CONFIG):
	./configure

$(EXECUTABLE): main.c $(CONFIG)
	$(CC) $(CFLAGS) -o $@ $<

install: $(EXECUTABLE)
	$(INSTALL) -d $(BINDIR)
	$(INSTALL) $(EXECUTABLE) $(BINDIR)/$(EXECUTABLE)

$(BATS):
	git submodule init
	git submodule update

clean:
	rm -f $(CONFIG) $(EXECUTABLE)

test: all $(BATS)
ifdef $CI
		$(BATS) --taps ./test
else
		$(BATS) ./test
endif

.PHONY: install clean test
