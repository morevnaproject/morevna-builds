DEPS=""

PK_DIRNAME="glew-2.0.0"
PK_ARCHIVE="$PK_DIRNAME.tgz"
PK_URL="https://sourceforge.net/projects/glew/files/glew/2.0.0/$PK_ARCHIVE/download"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    
    if ! GLEW_PREFIX=$INSTALL_PACKET_DIR GLEW_DEST=$INSTALL_PACKET_DIR make -j${THREADS}; then
        return 1
    fi
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! GLEW_PREFIX=$INSTALL_PACKET_DIR GLEW_DEST=$INSTALL_PACKET_DIR make install; then
        return 1
    fi
}
