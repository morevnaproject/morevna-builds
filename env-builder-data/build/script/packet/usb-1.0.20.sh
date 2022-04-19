DEPS=""

PK_DIRNAME="libusb-1.0.20"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="https://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-1.0.20/$PK_ARCHIVE/download"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    
	if ! check_packet_function $NAME build.configure; then
    	if ! ./configure --prefix=$INSTALL_PACKET_DIR; then
    		return 1
    	fi
		set_done $NAME build.configure
    fi
    
    if ! make; then
        return 1
    fi
}
