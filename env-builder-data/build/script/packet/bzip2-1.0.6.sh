
PK_DIRNAME="bzip2-1.0.6"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://sourceware.org/pub/bzip2/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1

    cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/Makefile" ./ || return 1
    patch "Makefile" "$FILES_PACKET_DIR/Makefile.patch" || return 1

    cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/bzip2.c" ./ || return 1
    patch "bzip2.c" "$FILES_PACKET_DIR/bzip2.c.patch" || return 1

    PREFIX="$INSTALL_PACKET_DIR" make -j${THREADS} libbz2.a || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1

    mkdir -p "$INSTALL_PACKET_DIR/include"
    cp -f bzlib.h "$INSTALL_PACKET_DIR/include/" || return 1
    
    mkdir -p "$INSTALL_PACKET_DIR/lib"
    cp -f libbz2.a "$INSTALL_PACKET_DIR/lib/"|| return 1
}
