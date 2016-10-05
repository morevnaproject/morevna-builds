DEPS="appimagekit-master opentoonz-master"

PK_APPIMAGEKIT_DIR=$PACKET_DIR/appimagekit-master/
PK_APPDIR_NAME="opentoonz"

pkinstall() {
	# copy files from envdeps (install requires envdeps explicit)
	
	local APPDIR="$INSTALL_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
	mkdir -p "$APPDIR/usr/lib"
	if ! cp --remove-destination "$ENVDEPS_PACKET_DIR/bin/AppRun" "$APPDIR/"; then
		return 1
	fi
	if ! cp --remove-destination "$ENVDEPS_PACKET_DIR/bin/desktopintegration" "$APPDIR/bin/launch-opentoonz.sh.wrapper"; then
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

	# copy files from envdeps_release (install_releas requires envdeps_release explicit)
	
	local APPDIR="$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
	if ! copy "$ENVDEPS_RELEASE_PACKET_DIR" "$APPDIR/usr"; then
		return 1
	fi
	if ! AppImageAssistant "$APPDIR" "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage"; then
		return 1
	fi
	rm -rf "$APPDIR"
}
