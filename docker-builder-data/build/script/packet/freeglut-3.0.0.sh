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
        local LOCAL_OPTIONS=
        if [ ! -z "$HOST" ]; then
            LOCAL_OPTIONS="$LOCAL_OPTIONS -DGNU_HOST=$HOST"
        fi
        if [ "$PLATFORM" = "win" ]; then
            LOCAL_OPTIONS="$LOCAL_OPTIONS -DCMAKE_TOOLCHAIN_FILE=mingw_cross_toolchain.cmake"
        fi
    	cmake \
    	   -DCMAKE_INSTALL_PREFIX=$INSTALL_PACKET_DIR \
    	   $LOCAL_OPTIONS . \
    	 || return 1
		set_done $NAME build.cunfigure
    fi
    
    make -j${THREADS} || return 1
}

