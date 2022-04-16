DEPS="zlib-1.2.11 ffi-3.2.1 pcre-8.37"
if [ "$PLATFORM" != "linux" ]; then
    DEPS_NATIVE="glib-2.69.3"
fi

PK_DIRNAME="glib-2.69.3"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/glib/2.69/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="--with-pcre=internal --disable-compile-warnings"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh


pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    #sed -i 's|https://ftp.pcre.org|http://ftp.exim.org|g' subprojects/libpcre.wrap
    if [[ $TC_HOST == "i686-w64-mingw32" ]]; then
        export WINEPATH="$ENVDEPS_PACKET_DIR/bin/"
        export CROSS_FILE="--cross-file /build/script/meson/linux-mingw-w64-32bit.txt"
    elif [[ $TC_HOST == "x86_64-w64-mingw32" ]]; then
        export WINEPATH="$ENVDEPS_PACKET_DIR/bin/"
        export CROSS_FILE="--cross-file /build/script/meson/linux-mingw-w64-64bit.txt"
    else
        export CROSS_FILE=""
    fi
    if [ -d _build ]; then
        export RECONFIGURE="--reconfigure"
    fi
    meson $RECONFIGURE _build $CROSS_FILE -Dprefix=${INSTALL_PACKET_DIR} || return 1
    ninja -C _build || return 1
    
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    ninja -C _build install || return 1
    
    if [ "$PLATFORM" = "win" ]; then
#        cat <<EOT >> ${INSTALL_PACKET_DIR}/bin/glib-compile-resources
##!/bin/bash
#
#glib-compile-resources "$@"
#EOT
#        chmod +x ${INSTALL_PACKET_DIR}/bin/glib-compile-resources
        sed -i 's|glib_compile_resources=.*|glib_compile_resources=glib-compile-resources|g' ${INSTALL_PACKET_DIR}/lib/pkgconfig/gio-2.0.pc
    fi
}
