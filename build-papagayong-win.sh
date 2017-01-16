#!/bin/bash

set -e

export IMAGE=build-fedora-cross-win
export TASK=papagayong-win

OLDDIR=`pwd`
BASE_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"
DATA_DIR="$BASE_DIR/docker-builder-data"
BUILD_DIR=$DATA_DIR/build
PUBLISH_DIR=$BASE_DIR/publish

CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi

run() {
	export SCRIPT="$BASE_DIR/docker/run.sh"
	export PLATFORM=win-${ARCH}
	export PLATFORM_SUFFIX=${ARCH}bit

	echo ""
	echo "Update papagayo-ng for ${PLATFORM}"
	echo ""
	
	$SCRIPT /build/script/common/manager.sh update papagayong-master
	$SCRIPT /build/script/common/manager.sh unpack papagayong-master
	
	# QUICK HACK:
	$SCRIPT /build/script/packet/papagayong-master.files/build-win.sh \
	        /build/packet/${PLATFORM}/papagayong-master
	
	local DIR="$PACKET_BUILD_DIR/$PLATFORM/papagayong-master/build"
	local FILE=`cd $DIR && ls -1 *.exe | head -n 1`
	local VERSION_FILE="$PACKET_BUILD_DIR/$PLATFORM/papagayong-master/unpack/version-papagayong-master"
	local VERSION=`echo "$FILE" | cut -d'-' -f 3`
	local COMMIT=`cat "$VERSION_FILE" | cut -d'-' -f 2-`
	COMMIT="${COMMIT:0:5}"
	local DATE=`date -u +%Y.%m.%d`
	if [ -z "$COMMIT" ]; then
		echo "Cannot find version, pheraps appimage not ready. Cancel."
		return 1
	fi
	if ! ls $PUBLISH_DIR/PapagayoNG-$VERSION-*-$COMMIT-win-installer.exe 1> /dev/null 2>&1; then
		echo "Publish new version $VERSION-$COMMIT-$PLATFORM"
		rm -f $PUBLISH_DIR/PapagayoNG-*-win-installer.exe
		cp "$DIR/$FILE" "$PUBLISH_DIR/PapagayoNG-$VERSION-$DATE-$COMMIT-win-installer.exe"
		if [ -f "$PUBLISH_DIR/publish-papagayong.sh" ]; then
			"$PUBLISH_DIR/publish-papagayong.sh" "$PUBLISH_DIR/PapagayoNG-$VERSION-$DATE-$COMMIT-win-installer.exe"
		fi
	else
		echo "Version $VERSION-$COMMIT-$PLATFORM_SUFFIX already published"
	fi
}

export ARCH=32
run
