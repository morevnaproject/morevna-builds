DEPS=""

PK_DIRNAME="SDL-1.2.15"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://www.libsdl.org/release/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS_DEFAULT="--host=$HOST --prefix=$INSTALL_PACKET_DIR"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    if ! check_packet_function $NAME build.cunfigure; then
        if [ "$PLATFORM" = "fedora" ]; then
            cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/src/video/x11/SDL_x11sym.h" "src/video/x11"
            patch "src/video/x11/SDL_x11sym.h" "$FILES_PACKET_DIR/SDL_x11sym.h.patch" || return 1
        fi
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
