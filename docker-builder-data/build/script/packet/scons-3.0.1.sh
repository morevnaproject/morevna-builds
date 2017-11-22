PK_DIRNAME="scons-3.0.1"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://prdownloads.sourceforge.net/scons/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    return 0
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    python setup.py install --prefix="$INSTALL_PACKET_DIR" || return 1
}
