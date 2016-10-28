DEPS=""

PK_DIRNAME="boost_1_61_0"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="https://sourceforge.net/projects/boost/files/boost/1.61.0/$PK_ARCHIVE/download"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
	if ! check_packet_function $NAME build.configure; then
		./bootstrap.sh --prefix=$INSTALL_PACKET_DIR --without-libraries=python || return 1
		set_done $NAME build.configure
	fi
	./b2 -j${THREADS} || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! ./b2 install; then
        return 1
    fi
}
