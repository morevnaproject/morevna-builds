DEPS=""

PK_DIRNAME="zlib-1.2.12"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://zlib.net/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS_DEFAULT="--prefix=$INSTALL_PACKET_DIR --shared"
PK_LICENSE_FILES="README"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

if [ "$PLATFORM" = "win" ]; then
pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    PREFIX=x86_64-w64-mingw32-
    if [[ $ARCH == "32" ]]; then
        PREFIX=i686-w64-mingw32-
    fi
    make -f win32/Makefile.gcc SHARED_MODE=1 PREFIX=${PREFIX} -j${THREADS} || return 1
}
pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    BINARY_PATH="$INSTALL_PACKET_DIR/bin" \
    INCLUDE_PATH="$INSTALL_PACKET_DIR/include" \
    LIBRARY_PATH="$INSTALL_PACKET_DIR/lib" \
    make -f win32/Makefile.gcc SHARED_MODE=1 install || return 1
}
fi
