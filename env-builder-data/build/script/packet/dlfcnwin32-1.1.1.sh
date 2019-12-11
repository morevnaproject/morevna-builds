
PK_DIRNAME="dlfcn-win32-1.1.1"
PK_ARCHIVE="v1.1.1.tar.gz"
PK_URL="https://github.com/dlfcn-win32/dlfcn-win32/archive/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh


pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1

    if ! check_packet_function $NAME build.configure; then
        cc="$CC" ./configure \
            --prefix="$INSTALL_PACKET_DIR" \
            --disable-static \
            --enable-shared \
         || return 1
        set_done $NAME build.configure
    fi
    
    make -j${THREADS} || return 1
}
 