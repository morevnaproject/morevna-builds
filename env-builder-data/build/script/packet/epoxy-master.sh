DEPS=""

PK_DIRNAME="libepoxy"
PK_URL="https://github.com/anholt/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="tags/1.4.2"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
	if ! check_packet_function $NAME build.cunfigure; then
    	./autogen.sh --host=$HOST --prefix=$INSTALL_PACKET_DIR || return 1
		set_done $NAME build.cunfigure
    fi
	make -j${THREADS} || return 1
}
