CC=cc
CFLAGS=-Wall
SOURCES=main.c
EXECUTABLE=bin/dns
BATS=test/bats/bin/bats
LAUNCH_H:=$(shell echo "\#include <launch.h>" | cc -E - &>/dev/null; echo $$?)

ifeq ($(LAUNCH_H),0)
	CFLAGS+=-DHAVE_LAUNCH_H
endif

all: $(EXECUTABLE)

$(EXECUTABLE): main.c bin
	$(CC) $(CFLAGS) -o $@ $<

bin:
	mkdir bin/

test/bats/bin/bats:
	git submodule init
	git submodule update

clean:
	rm -f $(EXECUTABLE)

test: all $(BATS)
ifdef $CI
		$(BATS) --taps ./test
else
		$(BATS) ./test
endif

.PHONY: clean test
