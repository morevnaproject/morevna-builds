#!/bin/bash

set -e

BASE_DIR=$(cd `dirname "$0"`; pwd)
DATA_DIR="$BASE_DIR/env-builder-data"
BUILD_DIR=$DATA_DIR/build
PUBLISH_DIR=$BASE_DIR/publish
CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
OPENTOONZ_TESTING_TAG="testing"

source "$BASE_DIR/gen-name.sh"

if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi

SCRIPT="$BASE_DIR/run.sh"

run_appimage() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update and build opentoonz for $PLATFORM-$ARCH"
    echo ""
    $SCRIPT chain update opentoonz-me \
            chain clean_before_do install_release opentoonz-me-appimage

    local TEMPLATE=`gen_name_template "OpenToonz" "$OPENTOONZ_TESTING_TAG" "$PLATFORM" "$ARCH" ".appimage"`
    "$PUBLISH_DIR/publish.sh" \
        "opentoonz-me" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-me-appimage/install_release" \
        "*.appimage" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-me-appimage/envdeps_release/version-opentoonz-me"
}

run_nsis() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update and build opentoonz for $PLATFORM-$ARCH"
    echo ""
    PLATFORM=win ARCH=32 $SCRIPT clean_before_do env zlib-1.2.12 # for NSIS
    $SCRIPT chain update opentoonz-me \
            chain clean_before_do install_release opentoonz-me-nsis \
            chain clean_before_do install_release opentoonz-me-portable

    local TEMPLATE=`gen_name_template "OpenToonz" "$OPENTOONZ_TESTING_TAG" "$PLATFORM" "$ARCH" ".exe"`
    "$PUBLISH_DIR/publish.sh" \
        "opentoonz-me" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-me-nsis/install_release" \
        "*.exe" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-me-nsis/envdeps_release/version-opentoonz-me"

    local TEMPLATE=`gen_name_template "OpenToonz" "$OPENTOONZ_TESTING_TAG" "$PLATFORM" "$ARCH" ".zip"`
    "$PUBLISH_DIR/publish.sh" \
        "opentoonz-me" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-me-portable/install_release" \
        "*.zip" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-me-portable/envdeps_release/version-opentoonz-me"
}

linux64() { run_appimage linux 64; }
linux32() { run_appimage linux 32; }
win64()   { run_nsis win 64; }
win32()   { run_nsis win 32; }

COMMANDS="$@"
if [ -z "$COMMANDS" ]; then COMMANDS="linux64 linux32 win64 win32"; fi
for COMMAND in $COMMANDS; do
    echo "Command: $COMMAND"
    $COMMAND
done

