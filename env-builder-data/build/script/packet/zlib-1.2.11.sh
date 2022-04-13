DEPS=""

PK_DIRNAME="zlib-1.2.11"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://altushost-swe.dl.sourceforge.net/project/libpng/zlib/1.2.11/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS_DEFAULT="--prefix=$INSTALL_PACKET_DIR --shared"
PK_LICENSE_FILES="README"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

if [ "$PLATFORM" = "win" ]; then
pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    cp "$FILES_PACKET_DIR/Makefile.mingw" .
    make -fMakefile.mingw SHARED_MODE=1 -j${THREADS} || return 1
}
pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    BINARY_PATH="$INSTALL_PACKET_DIR/bin" \
    INCLUDE_PATH="$INSTALL_PACKET_DIR/include" \
    LIBRARY_PATH="$INSTALL_PACKET_DIR/lib" \
    make -fMakefile.mingw SHARED_MODE=1 install || return 1
}
fi
