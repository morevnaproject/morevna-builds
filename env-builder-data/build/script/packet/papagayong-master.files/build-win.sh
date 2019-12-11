#!/bin/bash

# QUICK HACK:

set -e

PK_DIRNAME="papagayo-ng"

PREBUILT_URL="https://github.com/morevnaproject/papagayo-ng/releases/download/v1.4.0/papagayo-ng-1.4.0-win.zip"
PREBUILT_ZIP="papagayo-ng-1.4.0-win.zip"
PREBUILT_DIR="papagayo-ng-1.4.0-win"

VERSION=$(grep "export VERSION=" "$UNPACK_PACKET_DIR/$PK_DIRNAME/util/package-linux.sh" | cut -d\' -f 2)
TARGET_DIR="papagayo-ng-$VERSION-win"

foreachfile() {
    local FILE=$1
    local COMMAND=$2
    if [ ! -e "$FILE" ]; then
        return 1
    fi
    if [ -d "$FILE" ]; then    
        ls -A1 "$FILE" | while read SUBFILE; do
            if ! $COMMAND "$FILE/$SUBFILE" ${@:3}; then
                return 1
            fi
        done
    fi
}

nsis_register_file() {
    local FILE=$1
    local WIN_FILE=$(echo "$FILE" | sed "s|\/|\\\\|g")

    if [ "${FILE:0:2}" = "./" ]; then
        if [ -d "$FILE" ]; then
            foreachfile "$FILE" nsis_register_file
            echo "RMDir \"\$INSTDIR\\${WIN_FILE:2}\""               >> "files-uninstall.nsh" 
        else
            echo "Delete \"\$INSTDIR\\${WIN_FILE:2}\""              >> "files-uninstall.nsh" 
        fi
    else
        foreachfile $FILE nsis_register_file
    fi
}

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
	touch "files-uninstall.nsh"
	nsis_register_file .
	makensis papagayo-ng.nsi
	
	cd "$BUILD_PACKET_DIR"
	zip -r "$TARGET_DIR.zip" "$TARGET_DIR"
	rm -rf "$TARGET_DIR"
	mv "papagayo-ng-installer.exe" "papagayo-ng-$VERSION-win-installer.exe"
fi

