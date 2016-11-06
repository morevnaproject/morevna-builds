#!/bin/bash

set -e

export IMAGE=build-fedora-cross-win
export TASK=synfig-linux

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
	echo "Update synfigstudio for ${PLATFORM}"
	echo ""
	
	$SCRIPT /build/script/common/manager.sh update synfigstudio-master
	# QUICK HACK:
	$SCRIPT /build/packet/${PLATFORM}/synfigstudio-master/download/synfig/autobuild/fedora-crosscompile-win.sh
	#local DIR="$PACKET_BUILD_DIR/$PLATFORM/synfigstudio-appimage/install_release"
	#local VERSION_FILE="$PACKET_BUILD_DIR/$PLATFORM/synfigstudio-appimage/envdeps_release/version-synfigstudio-master"
	#local VERSION=`cat "$VERSION_FILE" | cut -d'-' -f 1`
	#local COMMIT=`cat "$VERSION_FILE" | cut -d'-' -f 2-`
	#COMMIT="${COMMIT:0:5}"
	#local DATE=`date -u +%Y.%m.%d`
	#if [ -z "$COMMIT" ]; then
	#	echo "Cannot find version, pheraps appimage not ready. Cancel."
	#	return 1
	#fi
	cd $PACKET_BUILD_DIR/$PLATFORM/synfigstudio-master/build
	FILE=`ls -1 *.exe | head -n 1`
if ! ls $PUBLISH_DIR/${FILE} 1> /dev/null 2>&1; then
		echo "Publish new version ${FILE}"
		rm -f $PUBLISH_DIR/${FILE} || true
		mv $PACKET_BUILD_DIR/$PLATFORM/synfigstudio-master/build/${FILE} $PUBLISH_DIR/
		if [ -f "$PUBLISH_DIR/publish-synfigstudio.sh" ]; then
			"$PUBLISH_DIR/publish-synfigstudio.sh" "$PUBLISH_DIR/${FILE}"
		fi
	else
		echo "Version ${FILE} already published"
	fi
}

if [ -z "$1" ] || [ -z "$2" ]; then
export ARCH=64
run
export ARCH=32
run
else
export ARCH=$2
run
fi
