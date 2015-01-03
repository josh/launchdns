CC=cc
CFLAGS=-Wall
SOURCES=main.c
EXECUTABLE=bin/dns
BATS=test/bats/bin/bats

all: $(EXECUTABLE)

$(EXECUTABLE): main.c bin
	$(CC) $(CFLAGS) -o $@ $<

bin:
	mkdir bin/

test/bats/bin/bats:
	git submodule init
	git submodule update

clean:
	rm $(EXECUTABLE)

test: all $(BATS)
ifdef $CI
		$(BATS) --taps ./test
else
		$(BATS) ./test
endif

.PHONY: clean test
