# make install DESTDIR=/home/yamo/devel/cc2/snap/parts/ccutter/install

LIBS=-ldl -lstdc++
COMFLAGS=-O2 -g
VERSION=$(shell cat Version)
DFLAGS=$(COMFLAGS) $(LDFLAGS) -I./src -J./src/c64 -J./src/font
CFLAGS:=$(COMFLAGS) $(CFLAGS)
CXXFLAGS=$(COMFLAGS) $(CPPFLAGS) -I./src 
COMPILE.d = $(DC) $(DFLAGS) -c
DC=gdc
EXE=
TARGET=ccutter
OBJ_EXT=.o

include Makefile.objects.mk

.PHONY: install release dist clean dclean tar

all: ct2util ccutter

ccutter:$(C64OBJS) $(OBJS) $(CXX_OBJS)
	$(DC) $(COMFLAGS) -o $@ $(OBJS) $(CXX_OBJS) $(LIBS)


.cpp.o : $(CXX_SRCS)
	$(CXX) $(CXXFLAGS) -c $< -o $@

.c.o : $(C_SRCS)
	$(CC) -c $< -o $@

ct: $(C64OBJS) $(CTOBJS)

ct2util: $(C64OBJS) $(UTILOBJS)
	$(DC) $(COMFLAGS) -o $@ $(UTILOBJS)

c64: $(C64OBJS)

install: all
	strip ccutter$(EXE)
	strip ct2util$(EXE)
	cp ccutter$(EXE) $(DESTDIR)
	cp ct2util$(EXE) $(DESTDIR)
	mkdir $(DESTDIR)/example_tunes
	cp -r tunes/* $(DESTDIR)/example_tunes

# release version with additional optimizations
release: DFLAGS += -frelease -fno-bounds-check
release: all
	strip ccutter$(EXE)
	strip ct2util$(EXE)

# tarred release
dist:	release
	tar --transform 's,^\.,cheesecutter-$(VERSION),' -cvf cheesecutter-$(VERSION)-linux-x86.tar.gz $(DIST_FILES)

clean: 
	rm -f *.o *~ resid/*.o resid-fp/*.o ccutter ct2util \
		$(C64OBJS) $(OBJS) $(CTOBJS) $(CXX_OBJS) $(UTILOBJS) $(C_OBJS)

dclean: clean
	rm -f cheesecutter-$(VERSION)-linux-x86.tar.gz

# tarred source from master
tar:
	git archive master --prefix=cheesecutter-$(VERSION)/ | bzip2 > cheesecutter-$(VERSION)-src.tar.bz2
# --------------------------------------------------------------------------------

src/c64/player.bin: src/c64/player_v4.acme
	acme -f cbm --outfile $@ $<

src/ct/base.o: src/c64/player.bin
src/ui/ui.o: src/ui/help.o

%.o: %.d
	$(COMPILE.d) -o $@ $<



