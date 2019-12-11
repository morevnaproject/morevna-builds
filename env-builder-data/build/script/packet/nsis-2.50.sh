DEPS="zlib-1.2.11"
DEPS_NATIVE="scons-3.0.1"

PK_DIRNAME="nsis-2.50-src"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="https://sourceforge.net/projects/nsis/files/NSIS%202/2.50/$PK_ARCHIVE"

#TODO: hardcoded path to mingw binaries
#TODO: untracked dependency for zlib win32

PK_PATH="/usr/local/i686-w64-mingw32/sys-root/bin:$PATH"
PK_ZLIB_W32="$PACKET_BUILD_DIR/win-32/zlib-1.2.11/env"
PK_NSIS_MAX_STRLEN=131072

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1

    pkhelper_patch Contrib/InstallOptions  InstallerOptions.cpp || return 1
    pkhelper_patch Contrib/Makensisw       makensisw.h          || return 1
    pkhelper_patch SCons/Config            gnu                  || return 1
    pkhelper_patch SCons/Tools             crossmingw.py        || return 1
    pkhelper_patch Source                  util.h               || return 1

    LDFLAGS="-static-libgcc -static-libstdc++ $LDFLAGS" \
    PATH="$PK_PATH" scons \
        PREFIX="$INSTALL_PACKET_DIR" \
        ZLIB_W32="$PK_ZLIB_W32" \
        SKIPUTILS="NSIS Menu" \
        NSIS_MAX_STRLEN=$PK_NSIS_MAX_STRLEN \
     || return 1 
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    LDFLAGS="-static-libgcc -static-libstdc++ $LDFLAGS" \
    PATH="$PK_PATH" scons \
        PREFIX="$INSTALL_PACKET_DIR" \
        ZLIB_W32="$PK_ZLIB_W32" \
        SKIPUTILS="NSIS Menu" \
        NSIS_MAX_STRLEN=$PK_NSIS_MAX_STRLEN \
        install \
     || return 1 
}
