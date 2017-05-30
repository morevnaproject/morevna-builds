DEPS=""

PK_DIRNAME="zlib-1.2.11"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://zlib.net/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS_DEFAULT="--prefix=$INSTALL_PACKET_DIR --shared"
PK_LICENSE_FILES="README"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

if [ "$PLATFORM" = "win" ]; then
pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    cp "$FILES_PACKET_DIR/Makefile.mingw" .
    make -fMakefile.mingw -j${THREADS} || return 1
}
pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    BINARY_PATH="$INTALL_PACKET_DIR/bin" \
    INCLUDE_PATH="$INTALL_PACKET_DIR/include" \
    LIBRARY_PATH="$INTALL_PACKET_DIR/lib" \
    make -fMakefile.mingw install || return 1
}
fi
