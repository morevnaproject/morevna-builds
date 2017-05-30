DEPS="png-1.6.26 glib-2.50.0"

PK_DIRNAME="qt-everywhere-opensource-src-5.7.0"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://download.qt.io/official_releases/qt/5.7/5.7.0/single/$PK_ARCHIVE"
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

            LOCAL_OPTIONS="-xplatform win32-g++ -device-option CROSS_COMPILE=$HOST-"
        fi
                                                                
        native_at_place \
           ./configure \
           -prefix "$INSTALL_PACKET_DIR" \
           $LOCAL_OPTIONS \
           -release \
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