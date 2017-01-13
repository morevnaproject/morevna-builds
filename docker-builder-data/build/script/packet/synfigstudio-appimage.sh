DEPS="appimagekit-master synfigstudio-master"

PK_APPIMAGEKIT_DIR=$PACKET_DIR/appimagekit-master/
PK_APPDIR_NAME="synfigstudio"

pkinstall() {
	# copy files from envdeps (install requires envdeps explicit)
	
	local APPDIR="$INSTALL_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
	mkdir -p "$APPDIR/usr"
	mkdir -p "$APPDIR/usr/bin"
	mkdir -p "$APPDIR/usr/lib"
	
	cp --remove-destination "$ENVDEPS_PACKET_DIR/bin/AppRun" "$APPDIR/" || return 1
	cp --remove-destination "$ENVDEPS_PACKET_DIR/bin/desktopintegration" "$APPDIR/usr/bin/synfigstudio.wrapper"|| return 1

	cp --remove-destination "$FILES_PACKET_DIR/synfigstudio.desktop" "$APPDIR/" || return 1
	cp --remove-destination "$FILES_PACKET_DIR/synfigstudio.png" "$APPDIR/" || return 1
	cp --remove-destination "$FILES_PACKET_DIR/launch.sh" "$APPDIR/usr/bin/" || return 1

	copy_system_lib libudev     "$APPDIR/usr/lib/" || return 1
	copy_system_lib libgfortran "$APPDIR/usr/lib/" || return 1
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
	
	# clean bin
	#rm -f $APPDIR/usr/bin/* || return 1
	#cp $INSTALL_PACKET_DIR/$PK_APPDIR_NAME.AppDir/usr/bin/*       $APPDIR/usr/bin/ || return 1
	#cp $ENVDEPS_RELEASE_PACKET_DIR/bin/melt                       $APPDIR/usr/bin/ || return 1
	#cp $ENVDEPS_RELEASE_PACKET_DIR/bin/identify                   $APPDIR/usr/bin/ || return 1
	#cp $ENVDEPS_RELEASE_PACKET_DIR/bin/synfig                     $APPDIR/usr/bin/ || return 1
	#cp $ENVDEPS_RELEASE_PACKET_DIR/bin/synfigstudio               $APPDIR/usr/bin/ || return 1
			
	# clean boost
	rm -f $APPDIR/usr/lib/libboost_* || return 1
	cp $ENVDEPS_RELEASE_PACKET_DIR/lib/libboost_chrono.*          $APPDIR/usr/lib/ || return 1
	cp $ENVDEPS_RELEASE_PACKET_DIR/lib/libboost_filesystem.*      $APPDIR/usr/lib/ || return 1
	cp $ENVDEPS_RELEASE_PACKET_DIR/lib/libboost_program_options.* $APPDIR/usr/lib/ || return 1
	cp $ENVDEPS_RELEASE_PACKET_DIR/lib/libboost_system.*          $APPDIR/usr/lib/ || return 1
	
	cd "$INSTALL_RELEASE_PACKET_DIR" || return 1
	rm -f "$PK_APPDIR_NAME.tar.gz" || return 1
	tar -czf "$PK_APPDIR_NAME.tar.gz" "$PK_APPDIR_NAME.AppDir" || return 1
	rm -f "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage" || return 1
	AppImageAssistant "$APPDIR" "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage" || return 1
	
	rm -rf "$APPDIR"
}
