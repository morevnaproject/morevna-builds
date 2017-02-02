#!/bin/bash

export TOOLCHAIN_HOST="x86_64-w64-mingw32"
export HOST="$TOOLCHAIN_HOST"

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:/usr/${TOOLCHAIN_HOST}/sys-root/mingw/lib/pkgconfig/
export PKG_CONFIG_LIBDIR=${PREFIX}/lib/pkgconfig
export PATH=/usr/${TOOLCHAIN_HOST}/bin:/usr/${TOOLCHAIN_HOST}/sys-root/mingw/bin:${PREFIX}/bin:$PATH
export LD_LIBRARY_PATH=${PREFIX}/lib:/usr/${TOOLCHAIN_HOST}/sys-root/mingw/lib:$LD_LIBRARY_PATH

export CC=/usr/bin/${TOOLCHAIN_HOST}-gcc
export CXX=/usr/bin/${TOOLCHAIN_HOST}-g++
export CFLAGS=" -I/usr/${TOOLCHAIN_HOST}/sys-root/mingw/include $CFLAGS"
export CPPFLAGS=" -I/usr/${TOOLCHAIN_HOST}/sys-root/mingw/include $CPPFLAGS"
export CXXFLAGS=" -I/usr/${TOOLCHAIN_HOST}/sys-root/mingw/include $CPPFLAGS"
export LDFLAGS=" -L/usr/${TOOLCHAIN_HOST}/sys-root/mingw/lib $LDFLAGS"
