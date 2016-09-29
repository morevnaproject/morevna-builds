DEPS="png-1.6.25 fuse-2.9.7 cmake-3.6.2"

PK_DIRNAME="AppImageKit"
PK_URL="https://github.com/probonopd/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
	
	if ! check_packet_function $NAME build.configure; then
		if ! cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PACKET_DIR .; then
    		return 1
    	fi
		set_done $NAME build.configure
    fi
	
	if ! make -j${THREADS}; then
		return 1
	fi
}
