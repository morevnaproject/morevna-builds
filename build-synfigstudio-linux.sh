#!/bin/bash

set -e

BASE_DIR=$(cd `dirname "$0"`; pwd)
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
	local SCRIPT=$1
	local PLATFORM=$2
	local PLATFORM_SUFFIX=$3

	echo ""
	echo "Update synfigstudio for $PLATFORM_SUFFIX"
	echo ""
	
	$SCRIPT update synfigetl-master
	$SCRIPT update synfigcore-master
	$SCRIPT update synfigstudio-master
	$SCRIPT clean_before_do install_release synfigstudio-appimage
	local DIR="$PACKET_BUILD_DIR/$PLATFORM/synfigstudio-appimage/install_release"
	local VERSION_FILE="$PACKET_BUILD_DIR/$PLATFORM/synfigstudio-appimage/envdeps_release/version-synfigstudio-master"
	local VERSION=`cat "$VERSION_FILE" | cut -d'-' -f 1`
	local COMMIT=`cat "$VERSION_FILE" | cut -d'-' -f 2-`
	COMMIT="${COMMIT:0:5}"
	local DATE=`date -u +%Y.%m.%d`
	if [ -z "$COMMIT" ]; then
		echo "Cannot find version, pheraps appimage not ready. Cancel."
		return 1
	fi
	if ! ls $PUBLISH_DIR/SynfigStudio-$VERSION-*-$COMMIT-$PLATFORM_SUFFIX.appimage 1> /dev/null 2>&1; then
		echo "Publish new version $VERSION-$COMMIT-$PLATFORM_SUFFIX"
		rm -f $PUBLISH_DIR/SynfigStudio-*-$PLATFORM_SUFFIX.appimage
		cp $DIR/synfigstudio.appimage $PUBLISH_DIR/SynfigStudio-$VERSION-$DATE-$COMMIT-$PLATFORM_SUFFIX.appimage
		if [ -f "$PUBLISH_DIR/publish-synfigstudio.sh" ]; then
			"$PUBLISH_DIR/publish-synfigstudio.sh" "$PUBLISH_DIR/SynfigStudio-$VERSION-$DATE-$COMMIT-$PLATFORM_SUFFIX.appimage"
		fi
	else
		echo "Version $VERSION-$COMMIT-$PLATFORM_SUFFIX already published"
	fi
}

run "$BASE_DIR/docker/debian-7-64bit/run.sh" "linux-x64" "64bits"
run "$BASE_DIR/docker/debian-7-32bit/run.sh" "linux-i386" "32bits"
