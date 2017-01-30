DEPS=""

PK_DIRNAME="Python-3.6.0"
PK_ARCHIVE="$PK_DIRNAME.tgz"
PK_URL="https://www.python.org/ftp/python/3.6.0/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkbuild-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    make install || return 1
    cd "$INSTALL_PACKET_DIR/bin" || return 1
    ln -s python3 python || return 1
}