#!/bin/bash

set -e

BASE_DIR=$(cd `dirname "$0"`; pwd)
DATA_DIR="$BASE_DIR/docker-builder-data"
BUILD_DIR=$DATA_DIR/build
PUBLISH_DIR=$BASE_DIR/publish
CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"

source "$BASE_DIR/gen-name.sh"

if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi

SCRIPT="$BASE_DIR/docker/run.sh"

run_appimage() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update and build opentoonz for $PLATFORM-$ARCH"
    echo ""
    $SCRIPT chain update opentoonz-master \
            chain clean_before_do install_release opentoonz-appimage

    local TEMPLATE=`gen_name_template "OpenToonz" "" "$PLATFORM" "$ARCH" ".appimage"`
    "$PUBLISH_DIR/publish.sh" \
        "opentoonz" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-appimage/install_release" \
        "*.appimage" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-appimage/envdeps_release/version-opentoonz-master"
}

run_nsis() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update and build opentoonz for $PLATFORM-$ARCH"
    echo ""
    $SCRIPT chain update opentoonz-master \
            chain clean_before_do install_release opentoonz-nsis

    local TEMPLATE=`gen_name_template "OpenToonz" "" "$PLATFORM" "$ARCH" ".exe"`
    "$PUBLISH_DIR/publish.sh" \
        "opentoonz" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-nsis/install_release" \
        "*.exe" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-nsis/envdeps_release/version-opentoonz-master"
}

run_appimage linux 64
run_appimage linux 32
run_nsis win 64
run_nsis win 32
