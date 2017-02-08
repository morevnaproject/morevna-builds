DEPS_NATIVE="cmake-3.6.2"

PK_DIRNAME="freeglut-3.0.0"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://prdownloads.sourceforge.net/freeglut/$PK_ARCHIVE?download"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    
	if ! check_packet_function $NAME build.cunfigure; then
    	if ! cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PACKET_DIR .; then
    		return 1
    	fi
		set_done $NAME build.cunfigure
    fi
    
    if ! make -j${THREADS}; then
        return 1
    fi
}

