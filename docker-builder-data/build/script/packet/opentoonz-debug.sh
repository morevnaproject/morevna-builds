DEPS="jpeg-9b png-1.6.26 lz4-master glew-2.0.0 usb-1.0.20 sdl-2.0.5 superlu-4.3 cmake-3.6.2 freeglut-3.0.0 openblas-master boost-1.61.0 qt-5.7"

PK_VERSION="1.1.1"
PK_DIRNAME="opentoonz"
PK_URL="https://github.com/opentoonz/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    if ! (cp --remove-destination "$FILES_PACKET_DIR/Makefile.in" "$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/" \
     && cp --remove-destination "$FILES_PACKET_DIR/FindTIFF.cmake" "$PK_DIRNAME/toonz/cmake/"); then
        return 1
    fi
	
	if ! check_packet_function $NAME build.libtiff; then
		cd "$BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3"
		if ! check_packet_function $NAME build.libtiff.configure; then
			if ! ./configure; then
	    		return 1
	    	fi
			set_done $NAME build.libtiff.configure
	    fi
		
		if ! make -j${THREADS}; then
    		return 1
    	fi
		set_done $NAME build.libtiff
    fi

	if ! cp --remove-destination "$ENVDEPS_PACKET_DIR/lib/libsuperlu_4.3.a" "$BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/superlu/libsuperlu_4.1.a"; then
		return 1
	fi

	mkdir -p "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
	cd "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
	if ! check_packet_function $NAME build.configure; then
		if ! cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PACKET_DIR ../sources; then
    		return 1
    	fi
		set_done $NAME build.configure
    fi
	
    # making in single thread is too slow, but life is too short...
	if ! (make -j${THREADS} || make -j${THREADS} || make); then
		return 1
	fi
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
    if ! make install; then
        return 1
    fi
    if ! cp --remove-destination "$FILES_PACKET_DIR/launch-opentoonz.sh" "$INSTALL_PACKET_DIR/bin"; then
        return 1
    fi
    if ! cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiff.so* "$INSTALL_PACKET_DIR/lib"; then
        return 1
    fi
    if ! cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiffxx.so* "$INSTALL_PACKET_DIR/lib"; then
        return 1
    fi
}
