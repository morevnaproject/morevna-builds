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

SCRIPT="$BASE_DIR/docker/run.sh"

run_appimage() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update papagayong for $PLATFORM-$ARCH"
    echo ""
    $SCRIPT update papagayong-testing
    $SCRIPT clean_before_do install_release papagayong-appimage

    "$PUBLISH_DIR/publish.sh" \
        "papagayong" \
        "PapagayoNG-%VERSION%-%DATE%-%COMMIT%-$PLATFORM-${ARCH}bit.appimage" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/papagayong-appimage/install_release" \
        "*.appimage" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/papagayong-appimage/envdeps_release/version-papagayong-testing"
}

run_nsis() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update papagayong for $PLATFORM-$ARCH"
    echo ""
    $SCRIPT update papagayong-testing
    $SCRIPT clean_before_do unpack papagayong-testing

    # QUICK HACK:
    $SCRIPT shell papagayong-testing "/build/script/packet/papagayong-testing.files/build-win.sh"

    "$PUBLISH_DIR/publish.sh" \
        "papagayong" \
        "PapagayoNG-%VERSION%-%DATE%-%COMMIT%-$PLATFORM-${ARCH}bit.exe" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/papagayong-testing/build" \
        "*.exe" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/papagayong-testing/unpack/version-papagayong-testing"
}

run_appimage linux 64
run_appimage linux 32
run_nsis win 32
