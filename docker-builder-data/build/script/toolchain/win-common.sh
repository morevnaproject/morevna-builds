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

export TC_PATH="/usr/$TC_HOST/bin:/usr/$TC_HOST/sys-root/mingw/bin:$INITIAL_PATH"
export TC_LD_LIBRARY_PATH="/usr/$TC_HOST/sys-root/mingw/lib:$INITIAL_LD_LIBRARY_PATH"

export TC_ADDR2LINE=/usr/bin/$TC_HOST-addr2line
export TC_AS=/usr/bin/$TC_HOST-as
export TC_AR=/usr/bin/$TC_HOST-ar
export TC_CC=/usr/bin/$TC_HOST-gcc
export TC_CXXFILT=/usr/bin/$TC_HOST-c++filt
export TC_CXX=/usr/bin/$TC_HOST-c++
export TC_CPP=/usr/bin/$TC_HOST-cpp
export TC_DLLTOOL=/usr/bin/$TC_HOST-dlltool
export TC_DLLWRAP=/usr/bin/$TC_HOST-dllwrap
export TC_ELFEDIT=/usr/bin/$TC_HOST-elfedit
export TC_FORTRAN=/usr/bin/$TC_HOST-gfortran
export TC_GXX=/usr/bin/$TC_HOST-g++
export TC_GCC=/usr/bin/$TC_HOST-gcc
export TC_GCOV=/usr/bin/$TC_HOST-gcov
export TC_GCOV_TOOL=/usr/bin/$TC_HOST-gcov-tool
export TC_GFORTRAN=/usr/bin/$TC_HOST-gfortran
export TC_GPROF=/usr/bin/$TC_HOST-gprof
export TC_LD=/usr/bin/$TC_HOST-ld
export TC_LD_BFD=/usr/bin/$TC_HOST-ld.bfd
export TC_NM=/usr/bin/$TC_HOST-nm
export TC_OBJCOPY=/usr/bin/$TC_HOST-objcopy
export TC_OBJDUMP=/usr/bin/$TC_HOST-objdump
export TC_PKG_CONFIG=/usr/bin/$TC_HOST-pkg-config
export TC_RANLIB=/usr/bin/$TC_HOST-ranlib
export TC_READELF=/usr/bin/$TC_HOST-readelf
export TC_SIZE=/usr/bin/$TC_HOST-size
export TC_STRINGS=/usr/bin/$TC_HOST-strings
export TC_STRIP=/usr/bin/$TC_HOST-strip
export TC_WINDMC=/usr/bin/$TC_HOST-windmc
export TC_RC=/usr/bin/$TC_HOST-windres
export TC_WINDRES=/usr/bin/$TC_HOST-windres

export TC_LDFLAGS=" -L/usr/$TC_HOST/sys-root/mingw/lib $INITIAL_LDFLAGS"
export TC_CFLAGS=" $TC_EXTRA_CPP_OPTIONS $INITIAL_CFLAGS"
export TC_CPPFLAGS=" $TC_EXTRA_CPP_OPTIONS $INITIAL_CPPFLAGS"
export TC_CXXFLAGS=" $TC_EXTRA_CPP_OPTIONS $INITIAL_CXXFLAGS"
export TC_PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/$TC_HOST/sys-root/mingw/lib/pkgconfig"
export TC_PKG_CONFIG_LIBDIR="/usr/$TC_HOST/sys-root/mingw/lib"
export TC_XDG_DATA_DIRS="$INITIAL_XDG_DATA_DIRS"
export TC_CMAKE_INCLUDE_PATH="$INITIAL_CMAKE_INCLUDE_PATH"
export TC_CMAKE_LIBRARY_PATH="/usr/$TC_HOST/sys-root/mingw/lib:$INITIAL_CMAKE_LIBRARY_PATH"

unset TC_EXTRA_CPP_OPTIONS
