#!/bin/bash

set -e

BASE_DIR=$(cd `dirname "$0"`; pwd)
DATA_DIR="$BASE_DIR/docker-builder-data"
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

SCRIPT="$BASE_DIR/docker/run.sh"

run_appimage() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update and build opentoonz for $PLATFORM-$ARCH"
    echo ""
    $SCRIPT chain update opentoonz-testing \
            chain clean_before_do install_release opentoonz-testingappimage

    local TEMPLATE=`gen_name_template "OpenToonz" "$OPENTOONZ_TESTING_TAG" "$PLATFORM" "$ARCH" ".appimage"`
    "$PUBLISH_DIR/publish.sh" \
        "opentoonz-testing" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-testingappimage/install_release" \
        "*.appimage" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-testingappimage/envdeps_release/version-opentoonz-testing"
}

run_nsis() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update and build opentoonz for $PLATFORM-$ARCH"
    echo ""
    PLATFORM=win ARCH=32 $SCRIPT clean_before_do env zlib-1.2.11 # for NSIS
    $SCRIPT chain update opentoonz-testing \
            chain clean_before_do install_release opentoonz-testingnsis \
            chain clean_before_do install_release opentoonz-testingportable

    local TEMPLATE=`gen_name_template "OpenToonz" "$OPENTOONZ_TESTING_TAG" "$PLATFORM" "$ARCH" ".exe"`
    "$PUBLISH_DIR/publish.sh" \
        "opentoonz-testing" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-testingnsis/install_release" \
        "*.exe" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-testingnsis/envdeps_release/version-opentoonz-testing"
    
    local TEMPLATE=`gen_name_template "OpenToonz" "$OPENTOONZ_TESTING_TAG" "$PLATFORM" "$ARCH" ".zip"`
    "$PUBLISH_DIR/publish.sh" \
        "opentoonz-testing" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-testingportable/install_release" \
        "*.zip" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/opentoonz-testingportable/envdeps_release/version-opentoonz-testing"
}

run_appimage linux 64
run_appimage linux 32
run_nsis win 64
run_nsis win 32
