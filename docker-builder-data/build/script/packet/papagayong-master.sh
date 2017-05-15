DEPS="wxphoenix-master python3pyaudio-master"

PK_DIRNAME="papagayo-ng"
PK_URL="https://github.com/morevnaproject/$PK_DIRNAME.git"

PK_LICENSE_FILES="readme.txt gpl.txt"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkbuild() {
	return 0
}

pkinstall() {
	mkdir -p "$INSTALL_PACKET_DIR/opt"
	local TARGET="$INSTALL_PACKET_DIR/opt/papagayong"
	rm -rf "$TARGET"
	cp -r "$BUILD_PACKET_DIR/$PK_DIRNAME" "$TARGET" || return 1

	mkdir -p "$INSTALL_PACKET_DIR/share/icons/default/128x128/apps"
	mkdir -p "$INSTALL_PACKET_DIR/share/icons/default/128x128/mimetypes"
		mkdir -p "$INSTALL_PACKET_DIR/share/mime"
	cp "$BUILD_PACKET_DIR/$PK_DIRNAME/rsrc/papagayo-ng.png" "$INSTALL_PACKET_DIR/share/icons/default/128x128/apps/papagayong.png" || return 1
	#cp "$BUILD_PACKET_DIR/$PK_DIRNAME/rsrc/papagayo-ng.png" "$INSTALL_PACKET_DIR/share/icons/default/128x128/mimetypes/application-x-papagayo.png" || return 1
	cp "$FILES_PACKET_DIR/papagayo.xml" "$INSTALL_PACKET_DIR/share/mime/" || return 1
	return 0
}
