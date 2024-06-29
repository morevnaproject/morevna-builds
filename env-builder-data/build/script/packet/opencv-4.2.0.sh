DEPS=""

PK_DIRNAME="opencv-4.2.0"
PK_ARCHIVE="opencv-4.2.0.tar.gz"
PK_URL="https://github.com/opencv/opencv/archive/refs/tags/4.2.0.tar.gz"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    
    if ! check_packet_function $NAME build.configure; then
        mkdir build && cd build
        cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_PACKET_DIR .. || return 1
        make -j8
        set_done $NAME build.configure
    fi
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    cd build
    make install
}
