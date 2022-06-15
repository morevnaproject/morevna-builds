#!/bin/bash

set -e

mkdir -p install-gcc
cd install-gcc

echo && echo "download and unpack" && echo

GCC_VERSION=7.2.0
GCC_SOURCES_URL="https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz"
wget -c "$GCC_SOURCES_URL"
tar -xf gcc-${GCC_VERSION}.tar.xz

echo && echo "build and install" && echo

mkdir -p build
cd build
[ -f "../configure.done" ] || (../gcc-${GCC_VERSION}/configure && touch "../configure.done")
make -j`nproc` || make
make install
(cd /usr/local/bin && ln gcc cc)
cd ..

echo && echo "add licenses" && echo

cd gcc-${GCC_VERSION}
PREFIX="/usr/local/share/doc"
TARGET="../copyright"
TARGET_DIRS="gcc g++ gfortran cc c++ fortran"
echo > "$TARGET"
for FILE in README COPYING* MAINTAINERS; do
    echo ""                                      >> "$TARGET"
    echo "-------------------------------------" >> "$TARGET"
    echo "  File: $FILE"                         >> "$TARGET"
    echo "-------------------------------------" >> "$TARGET"
    echo ""                                      >> "$TARGET"
    cat  "$FILE"                                 >> "$TARGET"
done
for TARGET_DIR in $TARGET_DIRS; do
    mkdir -p "$PREFIX/$TARGET_DIR"
    cp "$TARGET" "$PREFIX/$TARGET_DIR/"
done
cd ..

cd ..

echo && echo "clean" && echo

rm -r install-gcc
