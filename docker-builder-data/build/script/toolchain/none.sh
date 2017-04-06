#!/bin/bash

vars_clear "TC_"

# set vars which used explicitly in function manager.sh:set_environment_vars()

export TC_HOST=""

export TC_PATH="$INITIAL_PATH"
export TC_LD_LIBRARY_PATH="$INITIAL_LD_LIBRARY_PATH"

export TC_LDFLAGS="$INITIAL_LDFLAGS"
export TC_CFLAGS="$INITIAL_CFLAGS"
export TC_CPPFLAGS="$INITIAL_CPPFLAGS"
export TC_CXXFLAGS="$INITIAL_CXXFLAGS"

export TC_PKG_CONFIG_PATH="$INITIAL_PKG_CONFIG_PATH:/usr/share/pkgconfig:/usr/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/i386-linux-gnu/pkgconfig:/usr/lib/i586-linux-gnu/pkgconfig:/usr/lib/i686-linux-gnu/pkgconfig"
export TC_PKG_CONFIG_LIBDIR="$INITIAL_PKG_CONFIG_LIBDIR:/usr/lib:/usr/lib64:/usr/lib/x86_64-linux-gnu:/usr/lib/i686-linux-gnu"
export TC_XDG_DATA_DIRS="$INITIAL_XDG_DATA_DIRS"

export TC_ACLOCAL_PATH="/usr/share/aclocal"
if [ ! -z "$INITIAL_ACLOCAL_PATH" ]; then
    export TC_ACLOCAL_PATH="$INITIAL_ACLOCAL_PATH:$TC_ACLOCAL_PATH"
fi

export TC_CMAKE_INCLUDE_PATH="$INITIAL_CMAKE_INCLUDE_PATH"
export TC_CMAKE_LIBRARY_PATH="$INITIAL_CMAKE_LIBRARY_PATH"



