DEPS=""

PK_DIRNAME="synfig"
PK_URL="https://github.com/synfig/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
	cd "$BUILD_PACKET_DIR/$PK_DIRNAME/ETL" || return 1
	if ! check_packet_function $NAME build.configure; then
		autoreconf --install --force || return 1
		./configure --prefix=$INSTALL_PACKET_DIR || return 1
		set_done $NAME build.configure
	fi
	make -j${THREADS} || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/ETL"
    if ! make install; then
        return 1
    fi
}
