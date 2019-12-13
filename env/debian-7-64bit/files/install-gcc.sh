#!/bin/bash

set -e

mkdir -p install-gcc
cd install-gcc

echo && echo "download and unpack" && echo

GCC_SOURCES_URL="https://ftp.gnu.org/gnu/gcc/gcc-7.2.0/gcc-7.2.0.tar.xz"
wget -c "$GCC_SOURCES_URL"
tar -xf gcc-*.tar.*

echo && echo "build and install" && echo

mkdir -p build
cd build
[ -f "../configure.done" ] || (../gcc-*/configure && touch "../configure.done")
make -j`nproc` || make || make
make install
(cd /usr/local/bin && ln gcc cc)
cd ..

echo && echo "add licenses" && echo

cd gcc-*
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
