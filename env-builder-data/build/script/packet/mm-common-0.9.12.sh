PK_DIRNAME="mm-common-0.9.12"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/mm-common/0.9/$PK_ARCHIVE"
PK_LICENSE_FILES="AUTHORS COPYING COPYING.tools"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {

    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    
    if ! pkhook_prebuild; then
        return 1
    fi
    
    if ! check_packet_function $NAME build.configure; then
        CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" LDFLAGS="$PK_LDFLAGS $LDFLAGS" \
        ./autogen.sh \
            $PK_CONFIGURE_OPTIONS_DEFAULT \
            $PK_CONFIGURE_OPTIONS \
         || return 1
        set_done $NAME build.configure
    fi
    
    if ! CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" LDFLAGS="$PK_LDFLAGS $LDFLAGS" \
     make -j${THREADS}; then
        return 1
    fi
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    make install
}
