#!/bin/bash

# QUICK HACK:

set -e

ROOT_DIR=$1
SOURCE_DIR="$ROOT_DIR/unpack/papagayo-ng"
BUILD_DIR="$ROOT_DIR/build"
PREBUILT_URL="https://github.com/morevnaproject/papagayo-ng/releases/download/v1.4.0/papagayo-ng-1.4.0-win.zip"
PREBUILT_ZIP="papagayo-ng-1.4.0-win.zip"
PREBUILT_DIR="papagayo-ng-1.4.0-win"

VERSION=$(grep "export VERSION=" "$SOURCE_DIR/util/package-linux.sh" | cut -d\' -f 2)
TARGET_DIR="papagayo-ng-$VERSION-win"

if [ ! -f "$BUILD_DIR/papagayo-ng-$VERSION-win-installer.exe" ] \
|| [ "$BUILD_DIR/papagayo-ng-$VERSION-win-installer.exe" -ot "$ROOT_DIR/unpack.done" ]; then
	mkdir -p "$BUILD_DIR/prebuilt"
	
	cd "$BUILD_DIR/prebuilt"
	wget -c "$PREBUILT_URL"
	rm -rf "$TARGET_DIR"
	unzip "$PREBUILT_ZIP"
	
	cd "$BUILD_DIR"
	rm -f "$TARGET_DIR.zip"
	rm -rf "$TARGET_DIR"
	mv "prebuilt/$PREBUILT_DIR" "$TARGET_DIR"
	
	cd "$BUILD_DIR/$TARGET_DIR"
	rm -rf papagayo-ng
	ln -s "$SOURCE_DIR" papagayo-ng
	makensis papagayo-ng.nsi
	
	cd "$BUILD_DIR"
	zip -r "$TARGET_DIR.zip" "$TARGET_DIR"
	rm -rf "$TARGET_DIR"
	mv "papagayo-ng-installer.exe" "papagayo-ng-$VERSION-win-installer.exe"
fi

