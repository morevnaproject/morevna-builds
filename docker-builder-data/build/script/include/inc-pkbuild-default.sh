
# PK_DIRNAME
# PK_CONFIGURE_OPTIONS
# PK_CONFIGURE_OPTIONS_DEFAULT
# PK_CFLAGS
# PK_CPPFLAGS
# PK_LDFLAGS

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    
    if ! pkhook_prebuild; then
        return 1
    fi

    if ! check_packet_function $NAME build.configure; then
        CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" LDFLAGS="$PK_LDFLAGS $LDFLAGS" \
        ./configure \
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
