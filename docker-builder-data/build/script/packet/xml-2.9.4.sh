DEPS=""

PK_DIRNAME="libxml2-2.9.4"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://git.gnome.org/browse/libxml2/snapshot/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
	if ! check_packet_function $NAME build.cunfigure; then
	./autogen.sh --host=$HOST --prefix=$INSTALL_PACKET_DIR --without-python || return 1
		set_done $NAME build.cunfigure
    fi
    
    if ! make -j${THREADS}; then
        return 1
    fi
}
