DEPS="zlib-1.2.12"
DEPS_NATIVE="scons-3.0.1"

PK_DIRNAME="nsis-3.08-src"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="http://prdownloads.sourceforge.net/nsis/$PK_ARCHIVE"

#TODO: hardcoded path to mingw binaries
PK_PATH="/usr/i686-w64-mingw32/bin/:$PATH"
PK_ZLIB_W32="$PACKET_BUILD_DIR/win-32/zlib-1.2.12/install"
PK_NSIS_MAX_STRLEN=131072

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {

    PLATFORM=win ARCH=32 /build/script/common/manager.sh install_release zlib-1.2.12

    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    PATH="$PK_PATH" scons \
        PREFIX="$INSTALL_PACKET_DIR" \
        ZLIB_W32="$PK_ZLIB_W32" \
        SKIPUTILS="NSIS Menu" \
        NSIS_MAX_STRLEN=$PK_NSIS_MAX_STRLEN \
     || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    PATH="$PK_PATH" scons \
        PREFIX="$INSTALL_PACKET_DIR" \
        ZLIB_W32="$PK_ZLIB_W32" \
        SKIPUTILS="NSIS Menu" \
        NSIS_MAX_STRLEN=$PK_NSIS_MAX_STRLEN \
        install \
     || return 1
}
