DEPS=""

PK_DIRNAME="libxml2-2.9.4"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://software.morevnaproject.org/builder/src/libxml2/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
	if ! check_packet_function $NAME build.configure; then
	./autogen.sh --host=$HOST --prefix=$INSTALL_PACKET_DIR --without-python || return 1
		set_done $NAME build.configure
    fi
    
    if ! make -j${THREADS}; then
        return 1
    fi
}
