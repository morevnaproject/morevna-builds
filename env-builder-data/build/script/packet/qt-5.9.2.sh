DEPS="png-1.6.26 glib-2.69.3"

if [ "$PLATFORM" = "linux" ]; then
    DEPS="$DEPS pulseaudio-11.1"
fi

PK_DIRNAME="qt-everywhere-opensource-src-5.9.2"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.qt.io/archive/qt/5.9/5.9.2/single/$PK_ARCHIVE"

PK_LICENSE_FILES="LICENSE.LGPLv21"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

if [ "$PLATFORM" = "linux" ]; then
    DEPS="$DEPS xcbfull-1.12"
fi


pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"

    if ! check_packet_function $NAME build.configure; then
        local LOCAL_OPTIONS=
        if [ "$PLATFORM" = "win" ]; then
            rm -f "qtbase/mkspecs/win32-g++/qmake.conf" || return 1
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtbase/mkspecs/win32-g++/qmake.conf" \
             -i "$FILES_PACKET_DIR/qmake.conf.patch" -o - \
             > "qtbase/mkspecs/win32-g++/qmake.conf"

            rm -f "qtactiveqt/src/tools/idc/idc.pro" || return 1
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtactiveqt/src/tools/idc/idc.pro" \
             -i "$FILES_PACKET_DIR/idc.pro.patch" -o - \
             > "qtactiveqt/src/tools/idc/idc.pro"

            rm -f "qtbase/src/plugins/platforms/direct2d/direct2d.pro" || return 1
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtbase/src/plugins/platforms/direct2d/direct2d.pro" \
             -i "$FILES_PACKET_DIR/direct2d.pro.patch" -o - \
             > "qtbase/src/plugins/platforms/direct2d/direct2d.pro"
            
            rm -f "qtdeclarative/src/plugins/scenegraph/scenegraph.pro" || return 1
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtdeclarative/src/plugins/scenegraph/scenegraph.pro" \
             -i "$FILES_PACKET_DIR/Disable-d3d12-requiring-fxc.exe.patch" -o - \
             > "qtdeclarative/src/plugins/scenegraph/scenegraph.pro" || return 1
             
            rm -f "qtmultimedia/src/plugins/common/evr/evrdefs.h" || return 1
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtmultimedia/src/plugins/common/evr/evrdefs.h" \
             -i "$FILES_PACKET_DIR/qtmultimedia-mingw-MFVideoNormalizedRect.patch" -o - \
             > "qtmultimedia/src/plugins/common/evr/evrdefs.h" || return 1
            
            rm -f "qtmultimedia/src/plugins/directshow/directshow.pro" || return 1
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtmultimedia/src/plugins/directshow/directshow.pro" \
             -i "$FILES_PACKET_DIR/qtmultimedia.git-bc03bfdbcf63a81f7261637378e2447e76dc7e97.patch" -o - \
             > "qtmultimedia/src/plugins/directshow/directshow.pro" || return 1

            #rm -f "qtlocation/src/3rdparty/mapbox-gl-native/src/mbgl/gl/gl.hpp" || return 1
            #patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtlocation/src/3rdparty/mapbox-gl-native/src/mbgl/gl/gl.hpp" \
            # -i "$FILES_PACKET_DIR/gl.hpp.patch" -o - \
            # > "qtlocation/src/3rdparty/mapbox-gl-native/src/mbgl/gl/gl.hpp"

            LOCAL_OPTIONS=" \
                -xplatform win32-g++ \
                -device-option CROSS_COMPILE=$HOST- \
                -opengl desktop \
                -no-feature-geoservices_mapboxgl "
        fi

        rm -f "qtserialbus/src/plugins/canbus/socketcan/socketcanbackend.cpp" || return 1
        patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtserialbus/src/plugins/canbus/socketcan/socketcanbackend.cpp" \
         -i "$FILES_PACKET_DIR/socketcanbackend.cpp.patch" -o - \
         > "qtserialbus/src/plugins/canbus/socketcan/socketcanbackend.cpp"

        native_at_place with_envvar PATH "$PATH" \
           ./configure \
           -prefix "$INSTALL_PACKET_DIR" \
           $LOCAL_OPTIONS \
           -release \
           -shared \
           -opensource -confirm-license \
           -nomake examples \
         || return 1

        set_done $NAME build.configure
    fi

    native_at_place with_envvar PATH "$PATH" make -j${THREADS} || \
    native_at_place with_envvar PATH "$PATH" make || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    native_at_place with_envvar PATH "$PATH" make install || return 1
    
cat << EOF > "$INSTALL_PACKET_DIR/bin/qt.conf"
[Paths]
Prefix=..
EOF

    if [ ! $? -eq 0 ]; then
        return 1
    fi
}

pkhook_postinstall_release() {
    cd "$INSTALL_RELEASE_PACKET_DIR" || return 1
    rm -rf "examples" || return 1
    rm -rf "mkspecs" || return 1
    rm -rf "doc" || return 1
}
