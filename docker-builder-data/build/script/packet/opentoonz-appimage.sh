DEPS="appimagekit-master opentoonz-master"

PK_APPIMAGEKIT_DIR=$PACKET_DIR/appimagekit-master/
PK_APPDIR_NAME="opentoonz"

pkinstall() {
	# copy files from envdeps (install requires envdeps explicit)
	
	local APPDIR="$INSTALL_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
	mkdir -p "$APPDIR/usr"
	mkdir -p "$APPDIR/usr/bin"
	mkdir -p "$APPDIR/usr/lib"
	if ! cp --remove-destination "$ENVDEPS_PACKET_DIR/bin/AppRun" "$APPDIR/"; then
		return 1
	fi
	if ! cp --remove-destination "$ENVDEPS_PACKET_DIR/bin/desktopintegration" "$APPDIR/usr/bin/launch-opentoonz.sh.wrapper"; then
		return 1
	fi
    if ! (cp --remove-destination "$FILES_PACKET_DIR/opentoonz.desktop" "$APPDIR/" \
     && cp --remove-destination "$FILES_PACKET_DIR/opentoonz.png" "$APPDIR/"); then
        return 1
    fi
    if ! (cp --remove-destination /lib/x86_64-linux-gnu/libudev.so* "$APPDIR/usr/lib/" \
     || cp --remove-destination /lib/i386-linux-gnu/libudev.so* "$APPDIR/usr/lib/"); then
        return 1
    fi
    if ! (cp --remove-destination /usr/lib/x86_64-linux-gnu/libgfortran.so* "$APPDIR/usr/lib/" \
     || cp --remove-destination /usr/lib/i386-linux-gnu/libgfortran.so* "$APPDIR/usr/lib/"); then
        return 1
    fi
}

pkinstall_release() {
    if ! copy "$INSTALL_PACKET_DIR" "$INSTALL_RELEASE_PACKET_DIR"; then
        return 1
    fi

	# copy files from envdeps_release (install_release requires envdeps_release explicit)
	
	local APPDIR="$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
	copy "$ENVDEPS_RELEASE_PACKET_DIR" "$APPDIR/usr" || return 1
	
	# clean boost
	rm -f $APPDIR/usr/lib/libboost_* || return 1
	
	(cd "$INSTALL_RELEASE_PACKET_DIR" && tar -czf "$PK_APPDIR_NAME.tar.gz" "$PK_APPDIR_NAME.AppDir") || return 1
	AppImageAssistant "$APPDIR" "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage" || return 1
	rm -rf "$APPDIR"
}
