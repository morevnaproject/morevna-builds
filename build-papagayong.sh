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
    echo "Update and build  papagayong for $PLATFORM-$ARCH"
    echo ""
    $SCRIPT chain update papagayong-testing \
            chain clean_before_do install_release papagayong-appimage

    local TEMPLATE=`gen_name_template "PapagayoNG" "" "$PLATFORM" "$ARCH" ".appimage"`
    "$PUBLISH_DIR/publish.sh" \
        "papagayong" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/papagayong-appimage/install_release" \
        "*.appimage" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/papagayong-appimage/envdeps_release/version-papagayong-testing"
}

run_nsis() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update and build papagayong for $PLATFORM-$ARCH"
    echo ""
    # QUICK HACK:
    $SCRIPT chain update papagayong-testing \
            chain clean_before_do unpack papagayong-testing \
            chain shell papagayong-testing "/build/script/packet/papagayong-testing.files/build-win.sh"

    local TEMPLATE=`gen_name_template "PapagayoNG" "" "$PLATFORM" "$ARCH" ".exe"`
    "$PUBLISH_DIR/publish.sh" \
        "papagayong" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/papagayong-testing/build" \
        "*.exe" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/papagayong-testing/unpack/version-papagayong-testing"
}

run_appimage linux 64
run_appimage linux 32
run_nsis win 32
