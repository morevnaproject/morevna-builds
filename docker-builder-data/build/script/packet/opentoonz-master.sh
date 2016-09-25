DEPS="jpeg-9b png-1.6.25 lz4-master glew-2.0.0 usb-1.0.20 sdl-2.0.4 superlu-4.3 cmake-3.6.2 openblas-master boost-1.61.0 qt-5.7"

PK_DIRNAME="opentoonz"
PK_URL="https://github.com/opentoonz/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    if ! (cp "$FILES_PACKET_DIR/Makefile.in" "$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/" \
     && cp "$FILES_PACKET_DIR/FindTIFF.cmake" "$PK_DIRNAME/toonz/cmake/"); then
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

	if ! cp "$ENVDEPS_PACKET_DIR/lib/libsuperlu_4.3.a" "$BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/superlu/libsuperlu_4.1.a"; then
		return 1
	fi

	mkdir -p "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
	cd "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
	if ! check_packet_function $NAME build.configure; then
		if ! cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PACKET_DIR ../sources; then
    		return 1
    	fi
		set_done $NAME build.configure
    fi
	
	if ! make; then
		return 1
	fi
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
    if ! make install; then
        return 1
    fi
    if ! cp -f "$FILES_PACKET_DIR/launch-opentoonz.sh" "$INSTALL_PACKET_DIR/bin"; then
        return 1
    fi
}
