DEPS=""

PK_DIRNAME="boost_1_61_0"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="https://sourceforge.net/projects/boost/files/boost/1.61.0/$PK_ARCHIVE/download"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkinstall() {
	mkdir -p "$INSTALL_PACKET_DIR/include/boost"
	if ! copy "$BUILD_PACKET_DIR/$PK_DIRNAME/boost" "$INSTALL_PACKET_DIR/include/boost"; then
        return 1
    fi
}
