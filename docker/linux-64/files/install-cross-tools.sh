#!/bin/bash

set -e

VER_ICONV="1.15"
DIR_ICONV="libiconv-$VER_ICONV"
ARH_ICONV="$DIR_ICONV.tar.gz"
URL_ICONV="https://ftp.gnu.org/pub/gnu/libiconv/$ARH_ICONV"

#VER_GETTEXT="0.19.7"
VER_GETTEXT="0.20.2"
DIR_GETTEXT="gettext-$VER_GETTEXT"
ARH_GETTEXT="$DIR_GETTEXT.tar.gz"
URL_GETTEXT="https://ftp.gnu.org/pub/gnu/gettext/$ARH_GETTEXT"

INITIAL_PATH="$PATH"


download() {
    mkdir -p "/root/install-mingw/download"
    cd       "/root/install-mingw/download"
    echo && echo "download" && echo
    wget -c --no-cookies --max-redirect 40 "$URL_ICONV"
    wget -c --no-cookies --max-redirect 40 "$URL_GETTEXT"
    tar -xf "../download/$ARH_ICONV"
    tar -xf "../download/$ARH_GETTEXT"
}

install_iconv() {
    local ARCH="$1"
    export PATH="/usr/$ARCH/bin:$INITIAL_PATH"
    mkdir -p "/root/install-mingw/build/iconv-$ARCH"
    cd       "/root/install-mingw/build/iconv-$ARCH"
    echo && echo "install iconv $ARCH" && echo
        "../../download/$DIR_ICONV/configure" \
            --host="$ARCH" \
            --enable-static \
            --enable-shared \
            --with-sysroot="/usr/$ARCH" \
            --prefix="/usr/$ARCH"
    make -j$THREADS
    make install
    [ -d "/usr/share/licenses/iconv/" ] || mkdir -p "/usr/share/licenses/iconv/"
    cp -f ../../download/$DIR_ICONV/COPYING* "/usr/share/licenses/iconv/"
}

install_gettext() {
    local ARCH="$1"
    export PATH="/usr/$ARCH/bin:$INITIAL_PATH"
    mkdir -p "/root/install-mingw/build/gettext-$ARCH"
    cd       "/root/install-mingw/build/gettext-$ARCH"
    echo && echo "install gettext $ARCH" && echo
        "../../download/$DIR_GETTEXT/configure" \
            --host="$ARCH" \
            --disable-java \
            --disable-native-java \
            --disable-csharp \
            --enable-static \
            --enable-shared \
            --enable-threads=win32 \
            --without-emacs \
            --disable-openmp \
            --with-sysroot="/usr/$ARCH" \
            --prefix="/usr/$ARCH"
    make -j$THREADS
    make install
    [ -d "/usr/share/licenses/gettext/" ] || mkdir -p "/usr/share/licenses/gettext/"
    cp -f ../../download/$DIR_GETTEXT/COPYING* "/usr/share/licenses/gettext/"
}


install() {
    local ARCH="$1"
    install_iconv "$ARCH"
    install_gettext "$ARCH"
}

clean() {
    echo && echo "clean" && echo
    rm -r /root/install-mingw
}

download
install x86_64-w64-mingw32
install i686-w64-mingw32
clean

echo && echo "done" && echo
