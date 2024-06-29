DEPS=""

PK_DIRNAME="libjpeg-turbo-3.0.3"
PK_ARCHIVE="libjpeg-turbo-3.0.3.tar.gz"
PK_URL="https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.3/$PK_ARCHIVE"
PK_LICENSE_FILES="README.md"

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
