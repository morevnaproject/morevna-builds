DEPS="png-1.6.26 glib-2.50.0"

PK_DIRNAME="qt-everywhere-opensource-src-5.9.2"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="http://download.qt.io/official_releases/qt/5.9/5.9.2/single/$PK_ARCHIVE"
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
            rm -f "qtbase/mkspecs/win32-g++/qmake.conf"
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtbase/mkspecs/win32-g++/qmake.conf" \
             -i "$FILES_PACKET_DIR/qmake.conf.patch" -o - \
             > "qtbase/mkspecs/win32-g++/qmake.conf"

            rm -f "qtactiveqt/src/tools/idc/idc.pro"
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtactiveqt/src/tools/idc/idc.pro" \
             -i "$FILES_PACKET_DIR/idc.pro.patch" -o - \
             > "qtactiveqt/src/tools/idc/idc.pro"

            rm -f "qtbase/src/plugins/platforms/direct2d/direct2d.pro"
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtbase/src/plugins/platforms/direct2d/direct2d.pro" \
             -i "$FILES_PACKET_DIR/direct2d.pro.patch" -o - \
             > "qtbase/src/plugins/platforms/direct2d/direct2d.pro"

            # mingw bugs workarounds (https://sourceforge.net/p/mingw-w64/mailman/message/35627786/):

            rm -f "qtbase/src/plugins/platforms/direct2d/qwindowsdirect2dpaintengine.cpp"
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtbase/src/plugins/platforms/direct2d/qwindowsdirect2dpaintengine.cpp" \
             -i "$FILES_PACKET_DIR/qwindowsdirect2dpaintengine.cpp.patch" -o - \
             > "qtbase/src/plugins/platforms/direct2d/qwindowsdirect2dpaintengine.cpp"

            rm -f "qtbase/src/plugins/platforms/direct2d/qwindowsdirect2dintegration.cpp"
            patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtbase/src/plugins/platforms/direct2d/qwindowsdirect2dintegration.cpp" \
             -i "$FILES_PACKET_DIR/qwindowsdirect2dintegration.cpp.patch" -o - \
             > "qtbase/src/plugins/platforms/direct2d/qwindowsdirect2dintegration.cpp"

            LOCAL_OPTIONS="-xplatform win32-g++ -device-option CROSS_COMPILE=$HOST- -opengl desktop"
        fi

        rm -f "qtserialbus/src/plugins/canbus/socketcan/socketcanbackend.cpp"
        patch "$UNPACK_PACKET_DIR/$PK_DIRNAME/qtserialbus/src/plugins/canbus/socketcan/socketcanbackend.cpp" \
         -i "$FILES_PACKET_DIR/socketcanbackend.cpp.patch" -o - \
         > "qtserialbus/src/plugins/canbus/socketcan/socketcanbackend.cpp"

        native_at_place \
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

    native_at_place make -j${THREADS} || native_at_place make ||return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    make install || return 1
    
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