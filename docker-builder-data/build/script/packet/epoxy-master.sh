DEPS=""

PK_DIRNAME="libepoxy"
PK_URL="https://github.com/anholt/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
	if ! check_packet_function $NAME build.cunfigure; then
    	./autogen.sh --prefix=$INSTALL_PACKET_DIR || return 1
		set_done $NAME build.cunfigure
    fi
	make -j${THREADS} || return 1
}
