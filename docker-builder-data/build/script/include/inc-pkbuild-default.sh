
# PK_DIRNAME
# PK_CONFIGURE_OPTIONS
# PK_CFLAGS
# PK_CPPFLAGS

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
	if ! check_packet_function $NAME build.cunfigure; then
    	CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" \
    	 ./configure --prefix=$INSTALL_PACKET_DIR $PK_CONFIGURE_OPTIONS || return 1
		set_done $NAME build.cunfigure
    fi
    
    if ! CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" \
     make -j${THREADS}; then
        return 1
    fi
}
