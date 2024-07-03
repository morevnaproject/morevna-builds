DEPS="opentoonz-master"

PK_APPIMAGEKIT_DIR=$PACKET_DIR/appimagekit-master/
PK_APPDIR_NAME="opentoonz"

pkinstall() {
	# copy files from envdeps (install requires envdeps explicit)
	
	#local APPDIR="$INSTALL_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
	#mkdir -p "$APPDIR/usr"
	#mkdir -p "$APPDIR/usr/bin"
	#mkdir -p "$APPDIR/usr/lib"
	#cp --remove-destination "$ENVDEPS_NATIVE_PACKET_DIR/bin/AppRun" "$APPDIR/" || return 1
	#cp --remove-destination "$ENVDEPS_NATIVE_PACKET_DIR/bin/desktopintegration" "$APPDIR/usr/bin/launch-opentoonz.sh.wrapper" || return 1
	#cp --remove-destination "$FILES_PACKET_DIR/launch-opentoonz-appimage.sh" "$APPDIR/usr/bin/opentoonz-launch-appimage.sh" || return 1
	#cp --remove-destination "$FILES_PACKET_DIR/opentoonz.desktop" "$APPDIR/" || return 1
	#cp --remove-destination "$FILES_PACKET_DIR/opentoonz.png" "$APPDIR/" || return 1
	#mkdir -p "$APPDIR/usr/share/icons/default/128x128/apps/"
	#cp --remove-destination "$FILES_PACKET_DIR/opentoonz.png" "$APPDIR/usr/share/icons/default/128x128/apps/opentoonz.png" || return 1
	echo
}

pkinstall_release() {
	cp -rf "$INSTALL_PACKET_DIR" "$INSTALL_RELEASE_PACKET_DIR" || return 1
	
	# copy files from envdeps_release (install_release requires envdeps_release explicit)
	export APPDIR="$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.AppDir"
	[ -d $APPDIR ] || mkdir -p $APPDIR || return 1
	cp -rf "$ENVDEPS_RELEASE_PACKET_DIR" "$APPDIR/usr" || return 1

	# clean boost
	rm -f $APPDIR/usr/lib/libboost_* || return 1

	# fix crash on Ubuntu 20.04
	# https://github.com/morevnaproject-org/opentoonz/issues/39
	rm -f $APPDIR/usr/lib/libstdc* || return 1

	# fix https://github.com/morevnaproject-org/opentoonz/issues/13
	# "Could not Initialize GLX on Arch Linux"
	rm -f $APPDIR/usr/lib/libxcb-dri3* || return 1
	
	#rm -f $APPDIR/bin/gdbus || return 1
	#mkdir -p $APPDIR/usr/plugins/texttospeech
	
	if [ ! -f linuxdeploy-x86_64.AppImage ]; then
	wget -q -c 'https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage'
	fi
	if [ ! -f linuxdeploy-plugin-qt-x86_64.AppImage ]; then
        wget -q -c 'https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage'
	fi
	if [ ! -f linuxdeploy-plugin-appimage-x86_64.AppImage ]; then
        wget -q -c 'https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-x86_64.AppImage'
	fi
        chmod 755 linuxdeploy-x86_64.AppImage
        chmod 755 linuxdeploy-plugin-qt-x86_64.AppImage
        chmod 755 linuxdeploy-plugin-appimage-x86_64.AppImage
	
	cat << EOF > apprun.sh
#!/usr/bin/env bash
exec "\${APPDIR}/usr/bin/opentoonz" "\$@"
EOF
        chmod 755 apprun.sh
	
	
	
	LD_LIBRARY_PATH="$APPDIR/usr/lib:$APPDIR/usr/lib/opentoonz:$APPDIR/usr/lib64:$APPDIR/usr/lib/x86_64-linux-gnu:$APPDIR/usr/lib/pulseaudio:$APPDIR/usr/lib/pulse-11.1/modules" \
	./linuxdeploy-x86_64.AppImage --appdir=$APPDIR --plugin=qt --output=appimage --custom-apprun=apprun.sh \
        --executable=$APPDIR/usr/bin/lzocompress \
        --executable=$APPDIR/usr/bin/lzodecompress \
        --executable=$APPDIR/usr/bin/tcleanup \
        --executable=$APPDIR/usr/bin/tcomposer \
        --executable=$APPDIR/usr/bin/tconverter \
        --executable=$APPDIR/usr/bin/tfarmcontroller \
        --executable=$APPDIR/usr/bin/tfarmserver || bash
        mv OpenToonz*.AppImage "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage"

	#(cd "$INSTALL_RELEASE_PACKET_DIR" && tar -czf "$PK_APPDIR_NAME.tar.gz" "$PK_APPDIR_NAME.AppDir") || return 1
	#AppImageAssistant "$APPDIR" "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage" || return 1
	#rm -rf "$APPDIR"
}
