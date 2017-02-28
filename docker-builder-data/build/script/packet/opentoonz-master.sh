DEPS="jpeg-9b png-1.6.26 lz4-master glew-2.0.0 usb-1.0.20 sdl-2.0.5 superlu-5.2.1 freeglut-3.0.0 openblas-master boost-1.61.0 qt-5.7"
DEPS_NATIVE="cmake-3.6.2"

PK_VERSION="1.1.2"
PK_DIRNAME="opentoonz"
PK_URL="https://github.com/opentoonz/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    if ! check_packet_function $NAME build.libtiff; then
        cd "$BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3"
        if ! check_packet_function $NAME build.libtiff.configure; then
            CFLAGS="$CFLAGS -fPIC" ./configure || return 1
            set_done $NAME build.libtiff.configure
        fi
        make -j${THREADS} || return 1
        set_done $NAME build.libtiff
    fi

    mkdir -p "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
    if ! check_packet_function $NAME build.configure; then
        if ! cmake \
              -DCMAKE_PREFIX_PATH="$ENVDEPS_PACKET_DIR" \
              -DCMAKE_MODULE_PATH="$ENVDEPS_NATIVE_PACKET_DIR/share/cmake-3.6.2/Modules" \
              -DCMAKE_INSTALL_PREFIX="$INSTALL_PACKET_DIR" \
              -DPNG_PNG_INCLUDE_DIR="$ENVDEPS_PACKET_DIR/include" \
              -DPNG_LIBRARY="$ENVDEPS_PACKET_DIR/lib/libpng.so" \
              -DSUPERLU_INCLUDE_DIR="$ENVDEPS_PACKET_DIR/include/superlu-5.2.1/" \
              -DSUPERLU_LIBRARY="$ENVDEPS_PACKET_DIR/lib/libsuperlu_5.2.1.a" \
              -DLZO_INCLUDE_DIR="/usr/include/lzo" \
              ../sources; \
        then
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
    make install || return 1
    cp --remove-destination bin/lzo* "$INSTALL_PACKET_DIR/bin" || return 1
    cp --remove-destination "$FILES_PACKET_DIR/launch-opentoonz.sh" "$INSTALL_PACKET_DIR/bin" || return 1
    cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiff.so* "$INSTALL_PACKET_DIR/lib" || return 1
    cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiffxx.so* "$INSTALL_PACKET_DIR/lib" || return 1
}
