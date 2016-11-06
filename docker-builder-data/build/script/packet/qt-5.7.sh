DEPS="png-1.6.26 xcbfull-1.12 glib-2.50.0"

PK_DIRNAME="qt-everywhere-opensource-src-5.7.0"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://download.qt.io/official_releases/qt/5.7/5.7.0/single/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    
	if ! check_packet_function $NAME build.cunfigure; then
    	if ! ./configure -prefix "$INSTALL_PACKET_DIR" -opensource -confirm-license -no-compile-examples -nomake examples; then
    		return 1
    	fi
		set_done $NAME build.cunfigure
    fi
    
    # making in single thread is too slow, but life is too short...
	if ! (make -j${THREADS} || make -j${THREADS} || make); then
        return 1
    fi
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! make install; then
        return 1
    fi
    
cat << EOF > "$INSTALL_PACKET_DIR/bin/qt.conf"
[Paths]
Prefix=..
EOF

    if [ ! $? -eq 0 ]; then
        return 1
	fi
}
