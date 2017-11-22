DEPS="zlib-1.2.11"
DEPS_NATIVE="scons-3.0.1"

PK_DIRNAME="nsis-3.02.1-src"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="http://prdownloads.sourceforge.net/nsis/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    native_at_place with_envvar PATH "$PATH" scons \
        PREFIX="$INSTALL_PACKET_DIR" \
        ZLIB_W32="$ENVDEPS_PACKET_DIR" \
        SKIPUTILS="NSIS Menu" \
        NSIS_MAX_STRLEN=131072 \
     || return 1 
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    native_at_place with_envvar PATH "$PATH" scons \
        PREFIX="$INSTALL_PACKET_DIR" \
        ZLIB_W32="$ENVDEPS_PACKET_DIR" \
        SKIPUTILS="NSIS Menu" \
        NSIS_MAX_STRLEN=8192 \
        install \
     || return 1 
}
