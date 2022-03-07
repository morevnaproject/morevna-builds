#!/bin/bash

# TC_HOST should be set before inclusion of this file

export CROSS_TRIPLE="${TC_HOST}"
export CROSS_ROOT="/usr/${CROSS_TRIPLE}"

#export TC_PATH="${CROSS_ROOT}/bin:$INITIAL_PATH"
export TC_LD_LIBRARY_PATH="$CROSS_ROOT/lib:$INITIAL_LD_LIBRARY_PATH"

export TC_LDFLAGS=" -L${CROSS_ROOT}/lib -L/usr/lib/gcc/${CROSS_TRIPLE}/6.3-posix/ $INITIAL_LDFLAGS"

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
export TC_EXTRA_CPP_OPTIONS=""
export TC_CFLAGS=" $TC_EXTRA_CPP_OPTIONS $INITIAL_CFLAGS"
export TC_CPPFLAGS=" $TC_EXTRA_CPP_OPTIONS $INITIAL_CPPFLAGS"
export TC_CXXFLAGS=" $TC_EXTRA_CPP_OPTIONS $INITIAL_CXXFLAGS"
unset TC_EXTRA_CPP_OPTIONS

export TC_PKG_CONFIG_PATH=""
#export TC_PKG_CONFIG_LIBDIR="$CROSS_ROOT/lib"
#export TC_CMAKE_INCLUDE_PATH="${CROSS_ROOT}/include:$INITIAL_CMAKE_INCLUDE_PATH"
#export TC_CMAKE_LIBRARY_PATH="${CROSS_ROOT}/lib:$INITIAL_CMAKE_LIBRARY_PATH"

#export TC_ACLOCAL_PATH="/usr/share/aclocal"
#if [ ! -z "$INITIAL_ACLOCAL_PATH" ]; then
#    export TC_ACLOCAL_PATH="$INITIAL_ACLOCAL_PATH:$TC_ACLOCAL_PATH"
#fi

unset CROSS_ROOT

