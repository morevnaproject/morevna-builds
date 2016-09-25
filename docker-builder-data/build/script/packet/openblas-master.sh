DEPS=""

PK_DIRNAME="OpenBLAS"
PK_URL="https://github.com/xianyi/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! PREFIX=${INSTALL_PACKET_DIR} make -j${THREADS}; then
        return 1
    fi
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! PREFIX=${INSTALL_PACKET_DIR} make install; then
        return 1
    fi
}
