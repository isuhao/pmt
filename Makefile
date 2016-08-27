# Sample makefile for pngcrush using gcc and GNU make.
# Revised to build with INTEL_SSE2 and ARM_NEON support
# Glenn Randers-Pehrson
# Last modified:  27 August 2016
#
# Invoke this makefile from a shell prompt in the usual way; for example:
#
#	make -f makefile.gcc [OPTIONS=-Dsomething]
#
# This makefile builds a statically linked executable, using the bundled
# libpng and zlib code.

# macros --------------------------------------------------------------------

CC = gcc
LD = gcc
RM = rm -f

CFLAGS=-std=c90 

CFLAGS += -O3 -funroll-loops -fomit-frame-pointer

CPPFLAGS = ${OPTIONS}
CPPFLAGS += -I.
# CPPFLAGS="-I. -DPNG_DEBUG=5 -DPNG_RELEASE_BUILD=0"
# CPPFLAGS = -I${ZINC} -I.

# We don't need these
CPPFLAGS += -DNO_GZCOMPRESS -DNO_GZIP -DZ_SOLO -DNO_GZ
CFLAGS += -DNO_GZCOMPRESS -DNO_GZIP -DZ_SOLO -DNO_GZ

# use unified libpng
CPPFLAGS += -DLIBPNG_UNIFIED

# Enable timers
CPPFLAGS += -DPNGCRUSH_TIMERS=11
LIBS += -lrt

# Cannot use this with libpng15 and later.
# CPPFLAGS += -DINFLATE_ALLOW_INVALID_DISTANCE_TOOFAR_ARRR

LDFLAGS =
O = .o
E =

PNGCRUSH  = pngcrush

LIBS += -lm

# uncomment these 4 lines only if you are NOT using an external copy of zlib:
ZHDR = zlib.h
ZOBJS  = adler32$(O) compress$(O) crc32$(O) deflate$(O) \
	 infback$(O) inffast$(O) inflate$(O) inftrees$(O) \
	 trees$(O) uncompr$(O) zutil$(O)

# Enable INTEL SSE support
CPPFLAGS += -DPNG_INTEL_SSE

# Enable ARM_NEON support
CPPFLAGS += -DPNG_ARM_NEON

# unified libpng with separate zlib *.o
OBJS  = pngcrush$(O) $(ZOBJS)

EXES = $(PNGCRUSH)$(E)

# implicit make rules -------------------------------------------------------

.c$(O): png.h pngconf.h pngcrush.h cexcept.h pngpriv.h pnglibconf.h $(ZHDR)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $<


# dependencies --------------------------------------------------------------

all:  $(EXES)

inffast$(O): inffast.c
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $<

inflate$(O): inflate.c
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $<

deflate$(O): deflate.c
	$(CC) -c -DTOO_FAR=32767 $(CPPFLAGS) $(CFLAGS) $<

pngcrush$(O): pngcrush.c png.h pngconf.h pngcrush.h pnglibconf.h cexcept.h \
	$(ZHDR)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $<

$(PNGCRUSH)$(E): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

# maintenance ---------------------------------------------------------------

clean:
	$(RM) $(EXES) $(OBJS)
