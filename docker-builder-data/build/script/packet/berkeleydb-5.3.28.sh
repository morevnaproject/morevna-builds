DEPS=""

PK_DIRNAME="db-5.3.28/build_unix"
PK_ARCHIVE="db-5.3.28.tar.gz"
PK_URL="http://download.oracle.com/berkeley-db/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    if ! check_packet_function $NAME build.cunfigure; then
        CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" \
        ../dist/configure \
         $PK_CONFIGURE_OPTIONS_DEFAULT \
         $PK_CONFIGURE_OPTIONS \
         || return 1
        set_done $NAME build.cunfigure
    fi
    
    if ! CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" \
     make -j${THREADS}; then
        return 1
    fi
}
