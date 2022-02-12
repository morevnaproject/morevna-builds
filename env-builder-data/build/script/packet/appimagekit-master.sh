DEPS="png-1.6.26"
DEPS_NATIVE="cmake-3.12.4"

PK_DIRNAME="AppImageKit"
PK_URL="https://github.com/probonopd/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="d5102de21952217e2f9d0d2119442f843e0fa4dd"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
	
	if ! check_packet_function $NAME build.configure; then
		if ! cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PACKET_DIR .; then
    		return 1
    	fi
		set_done $NAME build.configure
    fi
	
	if ! make -j${THREADS}; then
		return 1
	fi
}

pkinstall() {
	mkdir -p "$INSTALL_PACKET_DIR/bin"
	if ! (cp --remove-destination "$BUILD_PACKET_DIR/$PK_DIRNAME/AppImageAssistant" "$INSTALL_PACKET_DIR/bin/" \
	 && cp --remove-destination "$BUILD_PACKET_DIR/$PK_DIRNAME/AppRun" "$INSTALL_PACKET_DIR/bin/" \
	 && cp --remove-destination "$BUILD_PACKET_DIR/$PK_DIRNAME/desktopintegration" "$INSTALL_PACKET_DIR/bin/" \
	 && chmod a+x "$INSTALL_PACKET_DIR/bin/desktopintegration"); then
		return 1
	fi
}
