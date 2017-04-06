DEPS_NATIVE="yasm-1.3.0"

PK_DIRNAME="x264"
PK_URL="http://git.videolan.org/git/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    
    if ! check_packet_function $NAME build.cunfigure; then
        AS=yasm ./configure \
         $PK_CONFIGURE_OPTIONS_DEFAULT \
         $PK_CONFIGURE_OPTIONS \
         || return 1
        set_done $NAME build.cunfigure
    fi
    
    if ! AS=yasm make -j${THREADS}; then
        return 1
    fi
}
