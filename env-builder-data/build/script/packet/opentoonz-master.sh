DEPS="jpeg-9b png-1.6.26 lz4-master lzo-2.10 lzma-5.2.3 glew-2.0.0 freeglut-3.0.0 superlu-5.2.1 openblas-0.3.3 boost-1.61.0 qt-5.9.2 mypaintlib-master"
DEPS_NATIVE="cmake-3.12.4"

PK_DIRNAME="opentoonz"
PK_URL="https://github.com/opentoonz/$PK_DIRNAME.git"
PK_LICENSE_FILES="README.md LICENSE.txt thirdparty/tiff-4.0.3/COPYRIGHT stuff/library/mypaint?brushes/Licenses.txt"

PK_CONFIGURE_OPTIONS=

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

if [ "$PLATFORM" = "linux" ]; then
    DEPS="$DEPS usb-1.0.20 sdl-2.0.5"
fi

pkhook_version() {
    local LOCAL_FILENAME="$PK_DIRNAME/toonz/sources/include/tversion.h"
    LANG=C LC_NUMERIC=C printf "%0.1f.%g\\n" \
      `cat "$LOCAL_FILENAME" | grep applicationVersion -m1 | cut -d "=" -f 2 | cut -d ";" -f 1` \
      `cat "$LOCAL_FILENAME" | grep applicationRevision -m1 | cut -d "=" -f 2 | cut -d ";" -f 1` \
    || return 1
}

pkbuild() {
    local LOCAL_OPTIONS=
    local LOCAL_CMAKE_OPTIONS=
    local LOCAL_PNG_LIB="libpng16.so"
    local LOCAL_GLUT_LIB="libglut.so"
    if [ ! -z "$HOST" ]; then
        LOCAL_OPTIONS="--host=$HOST"
    fi
    if [ "$PLATFORM" = "win" ]; then
        LOCAL_CMAKE_OPTIONS="$LOCAL_CMAKE_OPTIONS -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_C_COMPILER=${HOST}-gcc -DCMAKE_CXX_COMPILER=${HOST}-g++"
        LOCAL_PNG_LIB="libpng16.dll.a"
        LOCAL_GLUT_LIB="libfreeglut.dll.a"
    fi

    if ! check_packet_function $NAME libtiff.build; then
        cd "$BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3"
        if ! check_packet_function $NAME libtiff.build.configure; then
            CFLAGS="$CFLAGS -fPIC" ./configure $LOCAL_OPTIONS || return 1
           set_done $NAME libtiff.build.configure
        fi
        make clean
        make -j${THREADS} || return 1
        set_done $NAME libtiff.build
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
              -DPNG_LIBRARY="$ENVDEPS_PACKET_DIR/lib/$LOCAL_PNG_LIB" \
              -DGLUT_LIB="$ENVDEPS_PACKET_DIR/lib/$LOCAL_GLUT_LIB" \
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
        true
        #cp --remove-destination "$BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiff-5.dll" "$INSTALL_PACKET_DIR/bin/" || return 1
        #cp --remove-destination "$BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiffxx-5.dll" "$INSTALL_PACKET_DIR/bin/" || return 1
    else
        cp --remove-destination "$FILES_PACKET_DIR/launch-opentoonz.sh" "$INSTALL_PACKET_DIR/bin" || return 1
        cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiff.so* "$INSTALL_PACKET_DIR/lib" || return 1
        cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/thirdparty/tiff-4.0.3/libtiff/.libs/libtiffxx.so* "$INSTALL_PACKET_DIR/lib" || return 1
    fi

    if [ "$PLATFORM" = "win" ]; then
        local TARGET="$INSTALL_PACKET_DIR/bin/"
        
        local LOCAL_DIR="/usr/local/$HOST/sys-root/$HOST/lib/"
        cp "$LOCAL_DIR"/libgcc*.dll        "$TARGET" || return 1
        cp "$LOCAL_DIR"/libstdc*.dll       "$TARGET" || return 1
        cp "$LOCAL_DIR"/libquadmath*.dll   "$TARGET" || return 1
        cp "$LOCAL_DIR"/libgfortran*.dll   "$TARGET" || return 1

        local LOCAL_DIR="/usr/local/$HOST/sys-root/bin/"
        cp "$LOCAL_DIR"/libwinpthread*.dll "$TARGET" || return 1
        cp "$LOCAL_DIR"/libgettextlib*.dll "$TARGET" || return 1
        cp "$LOCAL_DIR"/libintl*.dll       "$TARGET" || return 1
        cp "$LOCAL_DIR"/libiconv*.dll      "$TARGET" || return 1

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
        copy_system_license gcc                    "$TARGET" || return 1
        copy_system_license mingw-w64              "$TARGET" || return 1
        copy_system_license gettext                "$TARGET" || return 1
        copy_system_license iconv                  "$TARGET" || return 1
    else
        copy_system_license gcc                    "$TARGET" || return 1
        copy_system_license libudev                "$TARGET" || return 1
    fi
}
