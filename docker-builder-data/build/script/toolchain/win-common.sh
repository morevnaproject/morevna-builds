#!/bin/bash

# TC_HOST should be set before inclusion of this file
#
# Optional c/c++ flags from Fedora MinGW:
#   -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4
#
#   -Wall -g            - don't need
#   -02 -fexceptions    - should be defined in packet if need
#   -pipe               - not compatible with windres (used in lzma packet)
#
#   -Wp,-D_FORTIFY_SOURCE=2 --param=ssp-buffer-size=4
#                       - may be better, but work fine without it, will added when any problem raised
#
# So no extra options for now
TC_EXTRA_CPP_OPTIONS=

TC_PREFIX="/usr/local/$TC_HOST/sys-root"
TC_BINPREFIX="$TC_PREFIX/bin/$TC_HOST"

export TC_PATH="$TC_PREFIX/bin:$INITIAL_PATH"
export TC_LD_LIBRARY_PATH="$TC_PREFIX/lib:/usr/local/lib:/usr/local/lib64:$INITIAL_LD_LIBRARY_PATH"

export TC_ADDR2LINE=$TC_BINPREFIX-addr2line
export TC_AS=$TC_BINPREFIX-as
export TC_AR=$TC_BINPREFIX-ar
export TC_CC=$TC_BINPREFIX-gcc
export TC_CXXFILT=$TC_BINPREFIX-c++filt
export TC_CXX=$TC_BINPREFIX-c++
export TC_CPP=$TC_BINPREFIX-cpp
export TC_DLLTOOL=$TC_BINPREFIX-dlltool
export TC_DLLWRAP=$TC_BINPREFIX-dllwrap
export TC_ELFEDIT=$TC_BINPREFIX-elfedit
export TC_FORTRAN=$TC_BINPREFIX-gfortran
export TC_GXX=$TC_BINPREFIX-g++
export TC_GCC=$TC_BINPREFIX-gcc
export TC_GCOV=$TC_BINPREFIX-gcov
export TC_GCOV_TOOL=$TC_BINPREFIX-gcov-tool
export TC_GFORTRAN=$TC_BINPREFIX-gfortran
export TC_GPROF=$TC_BINPREFIX-gprof
export TC_LD=$TC_BINPREFIX-ld
export TC_LD_BFD=$TC_BINPREFIX-ld.bfd
export TC_NM=$TC_BINPREFIX-nm
export TC_OBJCOPY=$TC_BINPREFIX-objcopy
export TC_OBJDUMP=$TC_BINPREFIX-objdump
export TC_RANLIB=$TC_BINPREFIX-ranlib
export TC_READELF=$TC_BINPREFIX-readelf
export TC_SIZE=$TC_BINPREFIX-size
export TC_STRINGS=$TC_BINPREFIX-strings
export TC_STRIP=$TC_BINPREFIX-strip
export TC_WINDMC=$TC_BINPREFIX-windmc
export TC_RC=$TC_BINPREFIX-windres
export TC_WINDRES=$TC_BINPREFIX-windres

export TC_LDFLAGS=" -L$TC_PREFIX/lib $INITIAL_LDFLAGS"
export TC_CFLAGS=" $TC_EXTRA_CPP_OPTIONS $INITIAL_CFLAGS"
export TC_CPPFLAGS=" $TC_EXTRA_CPP_OPTIONS $INITIAL_CPPFLAGS"
export TC_CXXFLAGS=" $TC_EXTRA_CPP_OPTIONS $INITIAL_CXXFLAGS"
export TC_PKG_CONFIG_PATH="$TC_PREFIX/lib/pkgconfig"
export TC_PKG_CONFIG_LIBDIR="$TC_PREFIX/lib"
export TC_XDG_DATA_DIRS="$INITIAL_XDG_DATA_DIRS"
export TC_CMAKE_INCLUDE_PATH="$TC_PREFIX/include:$INITIAL_CMAKE_INCLUDE_PATH"
export TC_CMAKE_LIBRARY_PATH="$TC_PREFIX/lib:$INITIAL_CMAKE_LIBRARY_PATH"

unset TC_BINPREFIX
unset TC_PREFIX
unset TC_EXTRA_CPP_OPTIONS
