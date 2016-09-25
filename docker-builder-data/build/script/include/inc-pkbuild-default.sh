
# PK_DIRNAME

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    
	if ! check_packet_function $NAME build.cunfigure; then
    	if ! ./configure --prefix=$INSTALL_PACKET_DIR; then
    		return 1
    	fi
		set_done $NAME build.cunfigure
    fi
    
    if ! make -j${THREADS}; then
        return 1
    fi
}
