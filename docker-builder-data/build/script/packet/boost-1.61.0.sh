DEPS=""

PK_DIRNAME="boost_1_61_0"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="https://sourceforge.net/projects/boost/files/boost/1.61.0/$PK_ARCHIVE/download"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! check_packet_function $NAME build.configure; then
        local LOCAL_PREFIX=$INSTALL_PACKET_DIR
        native ./bootstrap.sh --prefix=$LOCAL_PREFIX --without-libraries=python || return 1
        set_done $NAME build.configure
    fi
    
    local LOCAL_OPTIONS=
    if [ "$PLATFORM" = "win" ]; then
        LOCAL_OPTIONS="variant=release runtime-link=shared toolset=gcc-win binary-format=pe abi=ms target-os=windows --user-config=$BUILD_PACKET_DIR/$PK_DIRNAME/user-config.jam"
        echo "using gcc : win : $CXX : cflags=$CFLAGS cxxflags=$CXXFLAGS linkflags=$LDFLAGS ;" > user-config.jam
    fi
    ./b2 -j${THREADS} $LOCAL_OPTIONS || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    local LOCAL_OPTIONS=
    if [ "$PLATFORM" = "win" ]; then
        LOCAL_OPTIONS="variant=release runtime-link=shared toolset=gcc-win binary-format=pe abi=ms target-os=windows --user-config=$BUILD_PACKET_DIR/$PK_DIRNAME/user-config.jam"
    fi
    ./b2 $LOCAL_OPTIONS install || return 1
    rm -rf "$INSTALL_RELEASE_PACKET_DIR/include"
    remove_recursive "$INSTALL_RELEASE_PACKET_DIR/lib" *.a
}
