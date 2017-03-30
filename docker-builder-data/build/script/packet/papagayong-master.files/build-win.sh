#!/bin/bash

# QUICK HACK:

set -e

PK_DIRNAME="papagayo-ng"

PREBUILT_URL="https://github.com/morevnaproject/papagayo-ng/releases/download/v1.4.0/papagayo-ng-1.4.0-win.zip"
PREBUILT_ZIP="papagayo-ng-1.4.0-win.zip"
PREBUILT_DIR="papagayo-ng-1.4.0-win"

VERSION=$(grep "export VERSION=" "$UNPACK_PACKET_DIR/$PK_DIRNAME/util/package-linux.sh" | cut -d\' -f 2)
TARGET_DIR="papagayo-ng-$VERSION-win"

if [ ! -f "$BUILD_PACKET_DIR/papagayo-ng-$VERSION-win-installer.exe" ] \
|| [ "$BUILD_PACKET_DIR/papagayo-ng-$VERSION-win-installer.exe" -ot "$CURRENT_PACKET_DIR/unpack.done" ]; then
	mkdir -p "$BUILD_PACKET_DIR/prebuilt"
	
	cd "$BUILD_PACKET_DIR/prebuilt"
	wget -c "$PREBUILT_URL"
	rm -rf "$TARGET_DIR"
	unzip "$PREBUILT_ZIP"
	
	cd "$BUILD_PACKET_DIR"
	rm -f "$TARGET_DIR.zip"
	rm -rf "$TARGET_DIR"
	mv "prebuilt/$PREBUILT_DIR" "$TARGET_DIR"
	
	cd "$BUILD_PACKET_DIR/$TARGET_DIR"
	rm -rf papagayo-ng
	ln -s "$UNPACK_PACKET_DIR/$PK_DIRNAME" papagayo-ng
	cp "$FILES_PACKET_DIR/papagayo-ng.nsi" .
	cp "$FILES_PACKET_DIR/papagayo-ng.bat" .
	makensis papagayo-ng.nsi
	
	cd "$BUILD_PACKET_DIR"
	zip -r "$TARGET_DIR.zip" "$TARGET_DIR"
	rm -rf "$TARGET_DIR"
	mv "papagayo-ng-installer.exe" "papagayo-ng-$VERSION-win-installer.exe"
fi

