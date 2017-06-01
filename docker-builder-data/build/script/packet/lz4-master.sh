DEPS=""

PK_DIRNAME="lz4"
PK_URL="https://github.com/Cyan4973/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="tags/v1.7.5"
PK_LICENSE_FILES="LICENSE lib/LICENSE programs/COPYING tests/COPYING examples/COPYING"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

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
