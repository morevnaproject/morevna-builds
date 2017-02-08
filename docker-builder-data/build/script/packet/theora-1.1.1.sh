DEPS="ogg-1.3.2"

PK_DIRNAME="libtheora-1.1.1"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="http://downloads.xiph.org/releases/theora/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="--disable-examples"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    if ! check_packet_function $NAME build.cunfigure; then
        cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/configure" .
        patch configure "$FILES_PACKET_DIR/configure.patch"
        CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" \
        ./configure \
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
