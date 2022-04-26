DEPS="zlib-1.2.12 bzip2-1.0.6"

PK_DIRNAME="boost_1_61_0"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="https://sourceforge.net/projects/boost/files/boost/1.61.0/$PK_ARCHIVE/download"
PK_LICENSE_FILES="LICENSE_1_0.txt"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! check_packet_function $NAME build.configure; then
        local LOCAL_PREFIX=$INSTALL_PACKET_DIR
        native_at_place ./bootstrap.sh --prefix=$LOCAL_PREFIX --without-libraries=python || return 1
        set_done $NAME build.configure
    fi
    
    local LOCAL_OPTIONS=
    if [ "$PLATFORM" = "win" ]; then
        LOCAL_OPTIONS="variant=release runtime-link=shared toolset=gcc binary-format=pe abi=ms target-os=windows --user-config=$BUILD_PACKET_DIR/$PK_DIRNAME/user-config.jam"
        echo "using gcc : : ${TC_HOST}-g++ : <cflags>$CFLAGS <cxxflags>$CXXFLAGS <linkflags>$LDFLAGS ;" > user-config.jam
    fi
    ./b2 -j${THREADS} $LOCAL_OPTIONS || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    local LOCAL_OPTIONS=
    if [ "$PLATFORM" = "win" ]; then
        LOCAL_OPTIONS="variant=release runtime-link=shared toolset=gcc binary-format=pe abi=ms target-os=windows --user-config=$BUILD_PACKET_DIR/$PK_DIRNAME/user-config.jam"
    fi
    ./b2 $LOCAL_OPTIONS install || return 1
    rm -rf "$INSTALL_RELEASE_PACKET_DIR/include"
    remove_recursive "$INSTALL_RELEASE_PACKET_DIR/lib" *.a
}
