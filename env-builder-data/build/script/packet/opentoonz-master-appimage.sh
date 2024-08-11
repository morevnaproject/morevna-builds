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

	if [[ $ARCH == 64 ]]; then
		HOST_ARCH="x86_64"
		HOST="x86_64-linux-gnu"
	else
		HOST_ARCH="i386"
		HOST="i686-linux-gnu"
	fi
	if [ ! -f linuxdeploy-${HOST_ARCH}.AppImage ]; then
	wget -q -c 'https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20240109-1/'linuxdeploy-${HOST_ARCH}.AppImage
	fi
	if [ ! -f linuxdeploy-plugin-qt-${HOST_ARCH}.AppImage ]; then
	wget -q -c 'https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/1-alpha-20240109-1/'linuxdeploy-plugin-qt-${HOST_ARCH}.AppImage
	fi
	if [ ! -f linuxdeploy-plugin-appimage-${HOST_ARCH}.AppImage ]; then
	wget -q -c 'https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/1-alpha-20230713-1/'linuxdeploy-plugin-appimage-${HOST_ARCH}.AppImage
	fi
        chmod 755 linuxdeploy-${HOST_ARCH}.AppImage
        chmod 755 linuxdeploy-plugin-qt-${HOST_ARCH}.AppImage
        chmod 755 linuxdeploy-plugin-appimage-${HOST_ARCH}.AppImage
	
	cat << EOF > apprun.sh
#!/usr/bin/env bash
exec "\${APPDIR}/usr/bin/opentoonz" "\$@"
EOF
        chmod 755 apprun.sh
	
	
	LD_LIBRARY_PATH="$APPDIR/usr/lib:$APPDIR/usr/lib/opentoonz:$APPDIR/usr/lib${ARCH}:$APPDIR/usr/lib/${HOST}:$APPDIR/usr/lib/pulseaudio:$APPDIR/usr/lib/pulse-11.1/modules" \
	./linuxdeploy-${HOST_ARCH}.AppImage --appdir=$APPDIR --plugin=qt --output=appimage --custom-apprun=apprun.sh \
		--executable=$APPDIR/usr/bin/lzocompress \
		--executable=$APPDIR/usr/bin/lzodecompress \
		--executable=$APPDIR/usr/bin/tcleanup \
		--executable=$APPDIR/usr/bin/tcomposer \
		--executable=$APPDIR/usr/bin/tconverter \
		--executable=$APPDIR/usr/bin/tfarmcontroller \
		--executable=$APPDIR/usr/bin/tfarmserver
    
	# 32bit build fails on first run, but if started second time it builds fine
	[ -f OpenToonz-${HOST_ARCH}.AppImage ] || LD_LIBRARY_PATH="$APPDIR/usr/lib:$APPDIR/usr/lib/opentoonz:$APPDIR/usr/lib${ARCH}:$APPDIR/usr/lib/${HOST}:$APPDIR/usr/lib/pulseaudio:$APPDIR/usr/lib/pulse-11.1/modules" \
	./linuxdeploy-${HOST_ARCH}.AppImage --appdir=$APPDIR --plugin=qt --output=appimage --custom-apprun=apprun.sh \
		--executable=$APPDIR/usr/bin/lzocompress \
		--executable=$APPDIR/usr/bin/lzodecompress \
		--executable=$APPDIR/usr/bin/tcleanup \
		--executable=$APPDIR/usr/bin/tcomposer \
		--executable=$APPDIR/usr/bin/tconverter \
		--executable=$APPDIR/usr/bin/tfarmcontroller \
		--executable=$APPDIR/usr/bin/tfarmserver
	[ -f OpenToonz-${HOST_ARCH}.AppImage ] || bash
	mv OpenToonz-${HOST_ARCH}.AppImage "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage"

	#(cd "$INSTALL_RELEASE_PACKET_DIR" && tar -czf "$PK_APPDIR_NAME.tar.gz" "$PK_APPDIR_NAME.AppDir") || return 1
	#AppImageAssistant "$APPDIR" "$INSTALL_RELEASE_PACKET_DIR/$PK_APPDIR_NAME.appimage" || return 1
	#rm -rf "$APPDIR"
}
