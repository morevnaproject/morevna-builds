DEPS="papagayong-testing"
DEPS_NATIVE="appimagekit-master"

PK_APPIMAGEKIT_DIR=$PACKET_DIR/appimagekit-master/
PK_APPDIR_NAME="papagayong"

pkinstall() {
	# copy files from envdeps (install requires envdeps explicit)
	
	local APPDIR="$INSTALL_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
	mkdir -p "$APPDIR/usr"
	mkdir -p "$APPDIR/usr/bin"
	mkdir -p "$APPDIR/usr/lib"
	
	cp --remove-destination "$ENVDEPS_NATIVE_PACKET_DIR/bin/AppRun" "$APPDIR/" || return 1
	cp --remove-destination "$ENVDEPS_NATIVE_PACKET_DIR/bin/desktopintegration" "$APPDIR/usr/bin/papagayong.wrapper"|| return 1

	cp --remove-destination "$FILES_PACKET_DIR/papagayong.desktop" "$APPDIR/" || return 1
	cp --remove-destination "$FILES_PACKET_DIR/launch.sh" "$APPDIR/usr/bin/" || return 1
	cp --remove-destination "$FILES_PACKET_DIR/papagayong" "$APPDIR/usr/bin/" || return 1

    copy_system_gcc_libs        "$APPDIR/usr/lib/" || return 1
	copy_system_lib libudev     "$APPDIR/usr/lib/" || return 1
	copy_system_lib libpng12    "$APPDIR/usr/lib/" || return 1
	copy_system_lib libffi      "$APPDIR/usr/lib/" || return 1
	copy_system_lib libdb       "$APPDIR/usr/lib/" || return 1
	copy_system_lib libpcre     "$APPDIR/usr/lib/" || return 1
	copy_system_lib libdirect   "$APPDIR/usr/lib/" || return 1
	copy_system_lib libfusion   "$APPDIR/usr/lib/" || return 1
	copy_system_lib libbz2      "$APPDIR/usr/lib/" || return 1
}

pkinstall_release() {
    if ! copy "$INSTALL_PACKET_DIR" "$INSTALL_RELEASE_PACKET_DIR"; then
        return 1
    fi

	# copy files from envdeps_release (install_release requires envdeps_release explicit)

	local APPDIR="$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
	copy "$ENVDEPS_RELEASE_PACKET_DIR" "$APPDIR/usr" || return 1
	cp "$APPDIR/usr/share/icons/default/128x128/apps/papagayong.png" "$APPDIR/" || return 1

	cd "$INSTALL_RELEASE_PACKET_DIR" || return 1
	rm -f "$PK_APPDIR_NAME.tar.gz" || return 1
	tar -czf "$PK_APPDIR_NAME.tar.gz" "$PK_APPDIR_NAME.AppDir" || return 1
	rm -f "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage" || return 1
	AppImageAssistant "$APPDIR" "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage" || return 1
	
	rm -rf "$APPDIR"
}
