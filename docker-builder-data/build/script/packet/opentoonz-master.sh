DEPS="jpeg-9b png-1.6.26 lz4-master lzo-2.10 lzma-5.2.3 glew-2.0.0 freeglut-3.0.0 superlu-5.2.1 openblas-master boost-1.61.0 qt-5.9.2 mypaintlib-master"
DEPS_NATIVE="cmake-3.6.2"

PK_DIRNAME="opentoonz"
PK_URL="https://github.com/opentoonz/$PK_DIRNAME.git"
PK_LICENSE_FILES="README.md LICENSE.txt thirdparty/tiff-4.0.3/COPYRIGHT stuff/library/mypaint?brushes/Licenses.txt"

PK_CONFIGURE_OPTIONS=

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

if [ "$PLATFORM" = "linux" ]; then
    DEPS="$DEPS usb-1.0.20 sdl-2.0.5"
fi

pkhook_version() {
    cat "$PK_DIRNAME/toonz/sources/toonz/main.cpp" \
    | grep "const.char.\*applicationFullName.=.\"OpenToonz." \
    | cut -d \" -f 2 \
    | cut -d " " -f 2 \
    || return 1
}

pkbuild() {
    local LOCAL_OPTIONS=
    local LOCAL_CMAKE_OPTIONS=
    local LOCAL_LIB_SUFFIX="so"
    local LOCAL_GLUT_LIB="libglut"
    if [ ! -z "$HOST" ]; then
        LOCAL_OPTIONS="--host=$HOST"
    fi
    if [ "$PLATFORM" = "win" ]; then
        LOCAL_CMAKE_OPTIONS="$LOCAL_CMAKE_OPTIONS -DCMAKE_SYSTEM_NAME=Windows"
        LOCAL_LIB_SUFFIX="dll.a"
        LOCAL_GLUT_LIB="libfreeglut"
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
              -DPNG_PNG_INCLUDE_DIR="$ENVDEPS_PACKET_DIR/include" \
              -DPNG_LIBRARY="$ENVDEPS_PACKET_DIR/lib/libpng16.$LOCAL_LIB_SUFFIX" \
              -DGLUT_LIB="$ENVDEPS_PACKET_DIR/lib/$LOCAL_GLUT_LIB.$LOCAL_LIB_SUFFIX" \
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

    if [ "$PLATFORM" = "win" ]; then
        local TARGET="$INSTALL_PACKET_DIR/bin/"
        local LOCAL_DIR="/usr/$HOST/sys-root/mingw/bin/"
        cp "$LOCAL_DIR"/libgcc*.dll        "$TARGET" || return 1
        cp "$LOCAL_DIR"/libgfortran*.dll   "$TARGET" || return 1
        cp "$LOCAL_DIR"/libquadmath*.dll   "$TARGET" || return 1
        cp "$LOCAL_DIR"/libstdc*.dll       "$TARGET" || return 1
        cp "$LOCAL_DIR"/libwinpthread*.dll "$TARGET" || return 1
        cp "$LOCAL_DIR"/zlib*.dll          "$TARGET" || return 1
        cp "$LOCAL_DIR"/libgettextlib*.dll "$TARGET" || return 1
        cp "$LOCAL_DIR"/libintl*.dll       "$TARGET" || return 1
        cp "$LOCAL_DIR"/iconv*.dll         "$TARGET" || return 1
        cp "$LOCAL_DIR"/libtermcap*.dll    "$TARGET" || return 1
        cp "$LOCAL_DIR"/libpcre*.dll       "$TARGET" || return 1
        cp "$LOCAL_DIR"/libharfbuzz*.dll   "$TARGET" || return 1
        cp "$LOCAL_DIR"/libjasper*.dll     "$TARGET" || return 1
        cp "$LOCAL_DIR"/libjpeg*.dll       "$TARGET" || return 1

        # add icon
        cp "$BUILD_PACKET_DIR/$PK_DIRNAME/toonz/sources/toonz/toonz.ico" "$TARGET" || return 1
    else
        local TARGET="$INSTALL_PACKET_DIR/lib/"
        copy_system_gcc_libs               "$TARGET" || return 1
        copy_system_lib libudev            "$TARGET" || return 1
    fi
}

pkhook_postlicense() {
    local TARGET="$LICENSE_PACKET_DIR"
    if [ "$PLATFORM" = "win" ]; then
        local LOCAL_DIR="/usr/$HOST/sys-root/mingw/bin/"
        copy_system_license "mingw$ARCH-gcc gcc"   "$TARGET" || return 1
        copy_system_license mingw$ARCH-winpthreads "$TARGET" || return 1
        copy_system_license mingw$ARCH-gettext     "$TARGET" || return 1
        copy_system_license mingw$ARCH-win-iconv   "$TARGET" || return 1
        copy_system_license mingw$ARCH-termcap     "$TARGET" || return 1
    else
        copy_system_license gcc                    "$TARGET" || return 1
        copy_system_license libudev                "$TARGET" || return 1
    fi
}
