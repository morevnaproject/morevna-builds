DEPS="synfigstudio-me"
DEPS_NATIVE="appimagekit-master"

PK_APPIMAGEKIT_DIR=$PACKET_DIR/appimagekit-master/
PK_APPDIR_NAME="synfigstudio"

pkinstall() {
    # copy files from envdeps (install requires envdeps explicit)

    local APPDIR="$INSTALL_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
    mkdir -p "$APPDIR/usr"
    mkdir -p "$APPDIR/usr/bin"
    mkdir -p "$APPDIR/usr/lib"

    cp --remove-destination "$ENVDEPS_NATIVE_PACKET_DIR/bin/AppRun" "$APPDIR/" || return 1
    cp --remove-destination "$ENVDEPS_NATIVE_PACKET_DIR/bin/desktopintegration" "$APPDIR/usr/bin/synfigstudio.wrapper"|| return 1

    cp --remove-destination "$FILES_PACKET_DIR/synfigstudio.desktop" "$APPDIR/" || return 1
    cp --remove-destination "$FILES_PACKET_DIR/synfigstudio.png" "$APPDIR/" || return 1
    cp --remove-destination "$FILES_PACKET_DIR/launch.sh" "$APPDIR/usr/bin/" || return 1
    cp --remove-destination "$FILES_PACKET_DIR/fontconfig-warning.tcl" "$APPDIR/usr/bin/" || return 1
}

pkinstall_release() {
    if ! copy "$INSTALL_PACKET_DIR" "$INSTALL_RELEASE_PACKET_DIR"; then
        return 1
    fi

    # copy files from envdeps_release (install_release requires envdeps_release explicit)

    local APPDIR="$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
    copy "$ENVDEPS_RELEASE_PACKET_DIR" "$APPDIR/usr" || return 1
    
    mkdir -p "$APPDIR/usr/share/icons/default/128x128/apps/"
    mkdir -p "$APPDIR/usr/share/icons/default/128x128/mimetypes/"
    if [ -d "$ENVDEPS_RELEASE_PACKET_DIR/share/synfig/icons/classic/128x128/" ]; then
        cp "$ENVDEPS_RELEASE_PACKET_DIR/share/synfig/icons/classic/128x128/synfig_icon.png" "$APPDIR/usr/share/icons/default/128x128/apps/synfigstudio.png" || return 1
        cp "$ENVDEPS_RELEASE_PACKET_DIR/share/synfig/icons/classic/128x128/sif_icon.png" "$APPDIR/usr/share/icons/default/128x128/mimetypes/application-x-sif.png" || return 1
    elif [ -d "$ENVDEPS_RELEASE_PACKET_DIR/share/synfig/icons/classic/" ]; then
        cp "$ENVDEPS_RELEASE_PACKET_DIR/share/synfig/icons/classic/synfig_icon.png" "$APPDIR/usr/share/icons/default/128x128/apps/synfigstudio.png" || return 1
        cp "$ENVDEPS_RELEASE_PACKET_DIR/share/synfig/icons/classic/sif_icon.png" "$APPDIR/usr/share/icons/default/128x128/mimetypes/application-x-sif.png" || return 1
    else
        cp "$ENVDEPS_RELEASE_PACKET_DIR/share/pixmaps/synfig_icon.png" "$APPDIR/usr/share/icons/default/128x128/apps/synfigstudio.png" || return 1
        cp "$ENVDEPS_RELEASE_PACKET_DIR/share/pixmaps/sif_icon.png" "$APPDIR/usr/share/icons/default/128x128/mimetypes/application-x-sif.png" || return 1
    fi

    # clean bin
    #rm -f "$APPDIR/usr/bin/"* || return 1
    #cp "$INSTALL_PACKET_DIR/$PK_APPDIR_NAME.AppDir/usr/bin/"*       "$APPDIR/usr/bin/" || return 1
    #cp "$ENVDEPS_RELEASE_PACKET_DIR/bin/melt"                       "$APPDIR/usr/bin/" || return 1
    #cp "$ENVDEPS_RELEASE_PACKET_DIR/bin/identify"                   "$APPDIR/usr/bin/" || return 1
    #cp "$ENVDEPS_RELEASE_PACKET_DIR/bin/ffmpeg"                     "$APPDIR/usr/bin/" || return 1
    #cp "$ENVDEPS_RELEASE_PACKET_DIR/bin/synfig"                     "$APPDIR/usr/bin/" || return 1
    #cp "$ENVDEPS_RELEASE_PACKET_DIR/bin/synfigstudio"               "$APPDIR/usr/bin/" || return 1

    # clean boost
    rm -f "$APPDIR/usr/lib/libboost_"* || return 1
    cp "$ENVDEPS_RELEASE_PACKET_DIR/lib/libboost_chrono."*          "$APPDIR/usr/lib/" || return 1
    cp "$ENVDEPS_RELEASE_PACKET_DIR/lib/libboost_filesystem."*      "$APPDIR/usr/lib/" || return 1
    cp "$ENVDEPS_RELEASE_PACKET_DIR/lib/libboost_program_options."* "$APPDIR/usr/lib/" || return 1
    cp "$ENVDEPS_RELEASE_PACKET_DIR/lib/libboost_system."*          "$APPDIR/usr/lib/" || return 1

    # fix FONTCONFIG errors
    TARGET_DIR=../../../share/fontconfig/conf.avail
    pushd . >/dev/null 2>&1
    cd $APPDIR/usr/etc/fonts/conf.d
    rm -f ./*.conf
    for f in $TARGET_DIR/*.conf
    do
      ln -s -f $TARGET_DIR/${f##*/} ./${f##*/}
    done
    popd >/dev/null 2>&1

    # clean examples
    rm -rf "$APPDIR/share/synfig/examples" || return 1

	# move jack
	mkdir -p "$APPDIR/usr/lib.extra/jack"
	(cp "$ENVDEPS_RELEASE_PACKET_DIR/lib/libjack"* "$APPDIR/usr/lib.extra/jack" &> /dev/null) \
	|| (cp "$ENVDEPS_RELEASE_PACKET_DIR/lib64/libjack"* "$APPDIR/usr/lib.extra/jack" &> /dev/null)
    rm -f "$APPDIR/usr/bin/jack"*
	rm -f "$APPDIR/usr/lib/libjack"*
	rm -f "$APPDIR/usr/lib64/libjack"*
	
    cd "$INSTALL_RELEASE_PACKET_DIR" || return 1
    rm -f "$PK_APPDIR_NAME.tar.gz" || return 1
    tar -czf "$PK_APPDIR_NAME.tar.gz" "$PK_APPDIR_NAME.AppDir" || return 1
    rm -f "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage" || return 1
    AppImageAssistant "$APPDIR" "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage" || return 1

    rm -rf "$APPDIR"
}
