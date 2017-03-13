DEPS="jpeg-9b png-1.6.26 lz4-master lzo-2.10 lzma-5.2.3 glew-2.0.0 freeglut-3.0.0 superlu-5.2.1 openblas-master boost-1.61.0 qt-5.7"
DEPS_NATIVE="cmake-3.6.2"

PK_VERSION="1.1.2"
PK_DIRNAME="opentoonz"
PK_URL="https://github.com/opentoonz/$PK_DIRNAME.git"

PK_CONFIGURE_OPTIONS=

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

if [ "$PLATFORM" = "linux" ]; then
    DEPS="$DEPS usb-1.0.20 sdl-2.0.5"
fi

pkbuild() {
    local LOCAL_OPTIONS=
    local LOCAL_CMAKE_OPTIONS=
    if [ ! -z "$HOST" ]; then
        LOCAL_OPTIONS="--host=$HOST"
    fi
    if [ "$PLATFORM" = "win" ]; then
        LOCAL_CMAKE_OPTIONS="-DCMAKE_SYSTEM_NAME=Windows"
    fi

    if ! check_packet_function $NAME build.libtiff; then
        cd "$BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3"
        if ! check_packet_function $NAME build.libtiff.configure; then
            CFLAGS="$CFLAGS -fPIC" ./configure $LOCAL_OPTIONS || return 1
           set_done $NAME build.libtiff.configure
        fi
        make clean
        make -j${THREADS} || return 1
        set_done $NAME build.libtiff
    fi

    rm -rf "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
    mkdir -p "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
    if ! check_packet_function $NAME build.configure; then
        if ! cmake \
              -DCMAKE_PREFIX_PATH="$ENVDEPS_PACKET_DIR" \
              -DCMAKE_MODULE_PATH="$ENVDEPS_NATIVE_PACKET_DIR/share/cmake-3.6.2/Modules" \
              -DCMAKE_INSTALL_PREFIX="$INSTALL_PACKET_DIR" \
              $LOCAL_CMAKE_OPTIONS \
              $PK_CONFIGURE_OPTIONS \
              ../sources; \
        then
            return 1
        fi
        set_done $NAME build.configure
    fi
    
    make -j${THREADS} || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/build"
    make install || return 1
    if [ "$PLATFORM" = "win" ]; then
        cp --remove-destination "$BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiff-5.dll" "$INSTALL_PACKET_DIR/bin/" || return 1
        cp --remove-destination "$BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiffxx-5.dll" "$INSTALL_PACKET_DIR/bin/" || return 1
    else
        cp --remove-destination "$FILES_PACKET_DIR/launch-opentoonz.sh" "$INSTALL_PACKET_DIR/bin" || return 1
        cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiff.so* "$INSTALL_PACKET_DIR/lib" || return 1
        cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiffxx.so* "$INSTALL_PACKET_DIR/lib" || return 1
    fi
}

pkhook_postinstall_release() {
    if [ "$PLATFORM" = "win" ]; then
        local LOCAL_DIR="/usr/$HOST/sys-root/mingw/bin/"
        cp $LOCAL_DIR/libgcc*.dll        "$INSTALL_RELEASE_PACKET_DIR/bin/" || return 1
        cp $LOCAL_DIR/libgfortran*.dll   "$INSTALL_RELEASE_PACKET_DIR/bin/" || return 1
        cp $LOCAL_DIR/libquadmath*.dll   "$INSTALL_RELEASE_PACKET_DIR/bin/" || return 1
        cp $LOCAL_DIR/libstdc*.dll       "$INSTALL_RELEASE_PACKET_DIR/bin/" || return 1
        cp $LOCAL_DIR/libwinpthread*.dll "$INSTALL_RELEASE_PACKET_DIR/bin/" || return 1
        cp $LOCAL_DIR/zlib*.dll          "$INSTALL_RELEASE_PACKET_DIR/bin/" || return 1
        cp $LOCAL_DIR/libgettextlib*.dll "$INSTALL_RELEASE_PACKET_DIR/bin/" || return 1
        cp $LOCAL_DIR/libintl*.dll       "$INSTALL_RELEASE_PACKET_DIR/bin/" || return 1
        cp $LOCAL_DIR/iconv*.dll         "$INSTALL_RELEASE_PACKET_DIR/bin/" || return 1
        cp $LOCAL_DIR/libtermcap*.dll    "$INSTALL_RELEASE_PACKET_DIR/bin/" || return 1
    else
        copy_system_lib libudev     "$INSTALL_RELEASE_PACKET_DIR/lib/" || return 1
        copy_system_lib libgfortran "$INSTALL_RELEASE_PACKET_DIR/lib/" || return 1
        copy_system_lib libpng12    "$INSTALL_RELEASE_PACKET_DIR/lib/" || return 1
    fi
}
