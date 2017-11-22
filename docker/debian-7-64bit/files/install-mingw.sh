#!/bin/bash

set -e

VER_BINUTILS="2.29.1"
DIR_BINUTILS="binutils-$VER_BINUTILS"
ARH_BINUTILS="$DIR_BINUTILS.tar.xz"
URL_BINUTILS="https://ftp.gnu.org/gnu/binutils/$ARH_BINUTILS"

VER_GCC="7.2.0"
DIR_GCC="gcc-$VER_GCC"
ARH_GCC="$DIR_GCC.tar.xz"
URL_GCC="https://ftp.gnu.org/gnu/gcc/gcc-$VER_GCC/$ARH_GCC"

VER_MINGW="5.0.3"
DIR_MINGW="mingw-w64-v$VER_MINGW"
ARH_MINGW="$DIR_MINGW.tar.bz2"
URL_MINGW="https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/$ARH_MINGW"

VER_ICONV="1.15"
DIR_ICONV="libiconv-$VER_ICONV"
ARH_ICONV="$DIR_ICONV.tar.gz"
URL_ICONV="https://ftp.gnu.org/pub/gnu/libiconv/$ARH_ICONV"

VER_GETTEXT="0.19.7"
DIR_GETTEXT="gettext-$VER_GETTEXT"
ARH_GETTEXT="$DIR_GETTEXT.tar.gz"
URL_GETTEXT="https://ftp.gnu.org/pub/gnu/gettext/$ARH_GETTEXT"


THREADS=`nproc`
INITIAL_PATH="$PATH"
COMMAND="$0"


if [ "$1" == "host_install" ]; then
    PATH="/usr/local/$2/sys-root/bin:$PATH" make install
    exit
fi


download() {
    mkdir -p "install-mingw/download"
    cd       "install-mingw/download"
    if [ ! -f "done" ]; then
        echo && echo "download" && echo

        wget -c --no-cookies --max-redirect 40 "$URL_BINUTILS"
        wget -c --no-cookies --max-redirect 40 "$URL_GCC"
        wget -c --no-cookies --max-redirect 40 "$URL_MINGW"
        wget -c --no-cookies --max-redirect 40 "$URL_ICONV"
        wget -c --no-cookies --max-redirect 40 "$URL_GETTEXT"

        tar -xf "../download/$ARH_BINUTILS"
        tar -xf "../download/$ARH_GCC"
        tar -xf "../download/$ARH_MINGW"
        tar -xf "../download/$ARH_ICONV"
        tar -xf "../download/$ARH_GETTEXT"

        touch "done"
    fi
    cd ../..
}

install_binutils() {
    local ARCH="$1"
    mkdir -p "install-mingw/build/binutils-$ARCH"
    cd       "install-mingw/build/binutils-$ARCH"
    if [ ! -f "done" ]; then
        echo && echo "install binutils $ARCH" && echo
        if [ ! -f "configure.done" ]; then
            "../../download/$DIR_BINUTILS/configure" \
                --target="$ARCH" \
                --disable-multilib \
                --with-sysroot="/usr/local/$ARCH/sys-root" \
                --prefix="/usr/local/$ARCH/sys-root"
            touch "configure.done"
        fi
        make -j$THREADS || make
        sudo make install
        touch "done"
    fi
    cd ../../..
}

install_headers() {
    local ARCH="$1"
    mkdir -p "install-mingw/build/headers-$ARCH"
    cd       "install-mingw/build/headers-$ARCH"
    if [ ! -f "done" ]; then
        echo && echo "install headers $ARCH" && echo
        if [ ! -f "configure.done" ]; then
            "../../download/$DIR_MINGW/mingw-w64-headers/configure" \
                --host="$ARCH" \
                --prefix="/usr/local/$ARCH/sys-root"
            touch "configure.done"
        fi
        make -j$THREADS || make
        sudo make install
        pushd "/usr/local/$ARCH/sys-root"
        sudo ln -s . mingw
        popd
        touch "done"
    fi
    cd ../../..
}

install_gcc() {
    local ARCH="$1"
    mkdir -p "install-mingw/build/gcc-$ARCH"
    cd       "install-mingw/build/gcc-$ARCH"
    if [ ! -f "gcc.done" ]; then
        echo && echo "install gcc $ARCH" && echo
        if [ ! -f "configure.done" ]; then
            "../../download/$DIR_GCC/configure" \
                --target="$ARCH" \
                --disable-multilib \
                --enable-shared \
                --enable-threads=posix \
                --with-sysroot="/usr/local/$ARCH/sys-root" \
                --prefix="/usr/local/$ARCH/sys-root"
            touch "configure.done"
        fi
        make -j$THREADS all-gcc || make
        sudo make install-gcc
        touch "gcc.done"
    fi
    cd ../../..
}

install_crt() {
    local ARCH="$1"
    export PATH="/usr/local/$ARCH/sys-root/bin:$INITIAL_PATH"
    mkdir -p "install-mingw/build/crt-$ARCH"
    cd       "install-mingw/build/crt-$ARCH"
    if [ ! -f "done" ]; then
        echo && echo "install crt $ARCH" && echo
        if [ ! -f "configure.done" ]; then
            "../../download/$DIR_MINGW/mingw-w64-crt/configure" \
                --host="$ARCH" \
                --with-sysroot="/usr/local/$ARCH/sys-root" \
                --prefix="/usr/local/$ARCH/sys-root"
            touch "configure.done"
        fi
        make -j$THREADS || make
        sudo "../../../$0" host_install "$ARCH"
        touch "done"
    fi
    cd ../../..
}

finish_gcc() {
    local ARCH="$1"
    export PATH="/usr/local/$ARCH/sys-root/bin:$INITIAL_PATH"
    mkdir -p "install-mingw/build/gcc-$ARCH"
    cd       "install-mingw/build/gcc-$ARCH"
    if [ ! -f "done" ]; then
        echo && echo "finish gcc $ARCH" && echo
        make -j$THREADS || make
        sudo "../../../$0" host_install "$ARCH"
        touch "done"
    fi
    cd ../../..
}

install_library() {
    local ARCH="$1"
    local NAME="$2"
    export PATH="/usr/local/$ARCH/sys-root/bin:$INITIAL_PATH"
    mkdir -p "install-mingw/build/mingw-$NAME-$ARCH"
    cd       "install-mingw/build/mingw-$NAME-$ARCH"
    if [ ! -f "done" ]; then
        echo && echo "install library $NAME $ARCH" && echo
        if [ ! -f "configure.done" ]; then
            "../../download/$DIR_MINGW/mingw-w64-libraries/$NAME/configure" \
                --host="$ARCH" \
                --with-sysroot="/usr/local/$ARCH/sys-root" \
                --prefix="/usr/local/$ARCH/sys-root" \
                ${@:3}
            touch "configure.done"
        fi
        make -j$THREADS || make
        sudo "../../../$0" host_install "$ARCH"
        touch "done"
    fi
    cd ../../..
}

install_tool() {
    local ARCH="$1"
    local NAME="$2"
    export PATH="/usr/local/$ARCH/sys-root/bin:$INITIAL_PATH"
    mkdir -p "install-mingw/build/mingw-$NAME-$ARCH"
    cd       "install-mingw/build/mingw-$NAME-$ARCH"
    if [ ! -f "done" ]; then
        echo && echo "install tool $NAME $ARCH" && echo
        if [ ! -f "configure.done" ]; then
            "../../download/$DIR_MINGW/mingw-w64-tools/$NAME/configure" \
                --target="$ARCH" \
                --prefix="/usr/local/$ARCH/sys-root" \
                ${@:3}
            touch "configure.done"
        fi
        make -j$THREADS || make
        sudo "../../../$0" host_install "$ARCH"
        touch "done"
    fi
    cd ../../..
}

install_iconv() {
    local ARCH="$1"
    export PATH="/usr/local/$ARCH/sys-root/bin:$INITIAL_PATH"
    mkdir -p "install-mingw/build/iconv-$ARCH"
    cd       "install-mingw/build/iconv-$ARCH"
    if [ ! -f "done" ]; then
        echo && echo "install iconv $ARCH" && echo
        if [ ! -f "configure.done" ]; then
            "../../download/$DIR_ICONV/configure" \
                --host="$ARCH" \
                --enable-static \
                --enable-shared \
                --with-sysroot="/usr/local/$ARCH/sys-root" \
                --prefix="/usr/local/$ARCH/sys-root"
            touch "configure.done"
        fi
        make -j$THREADS || make
        sudo "../../../$0" host_install "$ARCH"
        touch "done"
    fi
    cd ../../..
}

install_gettext() {
    local ARCH="$1"
    export PATH="/usr/local/$ARCH/sys-root/bin:$INITIAL_PATH"
    mkdir -p "install-mingw/build/gettext-$ARCH"
    cd       "install-mingw/build/gettext-$ARCH"
    if [ ! -f "done" ]; then
        echo && echo "install gettext $ARCH" && echo
        if [ ! -f "configure.done" ]; then
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
                --with-sysroot="/usr/local/$ARCH/sys-root" \
                --prefix="/usr/local/$ARCH/sys-root"
            touch "configure.done"
        fi
        make -j$THREADS || make
        sudo "../../../$0" host_install "$ARCH"
        touch "done"
    fi
    cd ../../..
}

install_license() {
    local NAME="$1"
    local DIR_NAME="$2"
    cd "install-mingw/download/$DIR_NAME"
    if [ ! -f "../../build/$NAME.license.done" ]; then
        echo && echo "install license $NAME" && echo
        local TARGET="../../build/$NAME.license"
        echo > "$TARGET"
        for FILE in README COPYING* MAINTAINERS AUTHORS; do
            if [ -f "$FILE" ]; then
                echo ""                                      >> "$TARGET"
                echo "-------------------------------------" >> "$TARGET"
                echo "  File: $FILE"                         >> "$TARGET"
                echo "-------------------------------------" >> "$TARGET"
                echo ""                                      >> "$TARGET"
                cat  "$FILE"                                 >> "$TARGET"
            fi
        done
        sudo mkdir -p "/usr/local/share/doc/$NAME"
        sudo cp "$TARGET" "/usr/local/share/doc/$NAME/copyright"
        touch "../../build/$NAME.license.done"
    fi
    cd ../../..
}


install() {
    local ARCH="$1"
    install_binutils "$ARCH"
    install_headers "$ARCH"
    install_gcc "$ARCH"
    install_crt "$ARCH"
    install_library "$ARCH" "winpthreads"
    finish_gcc "$ARCH"

    install_library "$ARCH" "libmangle"
    install_library "$ARCH" "winstorecompat"
    install_tool "$ARCH" "gendef"
    install_tool "$ARCH" "genidl"
    install_tool "$ARCH" "genlib"
    install_tool "$ARCH" "genpeimg"
    install_tool "$ARCH" "widl"

    install_iconv "$ARCH"
    install_gettext "$ARCH"

    install_license gcc      "$DIR_GCC"
    install_license g++      "$DIR_GCC"
    install_license gfortran "$DIR_GCC"
    install_license cc       "$DIR_GCC"
    install_license c++      "$DIR_GCC"
    install_license gfortran "$DIR_GCC"

    install_license mingw-w64 "$DIR_MINGW"
    install_license iconv "$DIR_ICONV"
    install_license gettext "$DIR_GETTEXT"
}

clean() {
    echo && echo "clean" && echo
    rm -r install-mingw
}

download
install x86_64-w64-mingw32
install i686-w64-mingw32
clean

echo && echo "done" && echo
