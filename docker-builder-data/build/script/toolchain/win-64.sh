#!/bin/bash

export TOOLCHAIN_HOST="x86_64-w64-mingw32"
export TOOLCHAIN_PATH="/usr/$TOOLCHAIN_HOST/bin:/usr/$TOOLCHAIN_HOST/sys-root/mingw/bin:$INITIAL_PATH"
export TOOLCHAIN_LD_LIBRARY_PATH="/usr/$TOOLCHAIN_HOST/sys-root/mingw/lib:$INITIAL_LD_LIBRARY_PATH"
export TOOLCHAIN_CC=/usr/bin/$TOOLCHAIN_HOST-gcc
export TOOLCHAIN_CXX=/usr/bin/$TOOLCHAIN_HOST-g++
export TOOLCHAIN_LDFLAGS=" -L/usr/$TOOLCHAIN_HOST/sys-root/mingw/lib $INITIAL_LDFLAGS"
export TOOLCHAIN_CFLAGS=" -I/usr/$TOOLCHAIN_HOST/sys-root/mingw/include $INITIAL_CFLAGS"
export TOOLCHAIN_CPPFLAGS=" -I/usr/$TOOLCHAIN_HOST/sys-root/mingw/include $INITIAL_CPPFLAGS"
export TOOLCHAIN_CXXFLAGS=" -I/usr/$TOOLCHAIN_HOST/sys-root/mingw/include $INITIAL_CXXFLAGS"
export TOOLCHAIN_PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/$TOOLCHAIN_HOST/sys-root/mingw/lib/pkgconfig/"
export TOOLCHAIN_XDG_DATA_DIRS="$INITIAL_XDG_DATA_DIRS"
export TOOLCHAIN_ACLOCAL_PATH="$INITIAL_ACLOCAL_PATH"

