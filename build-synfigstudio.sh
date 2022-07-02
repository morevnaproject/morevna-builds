#!/bin/bash

set -e

BASE_DIR=$(cd `dirname "$0"`; pwd)
DATA_DIR="$BASE_DIR/env-builder-data"
BUILD_DIR=$DATA_DIR/build
PUBLISH_DIR=$BASE_DIR/publish
CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
SYNFIGSTUDIO_TESTING_TAG="testing"

source "$BASE_DIR/gen-name.sh"

if [ -f $CONFIG_FILE ]; then
    source $CONFIG_FILE
fi

SCRIPT="$BASE_DIR/run.sh"

run_appimage() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update and build synfigstudio for $PLATFORM-$ARCH"
    echo ""
    $SCRIPT chain native update synfigetl-master \
            chain native update synfigcore-master \
            chain update synfigetl-master \
            chain update synfigcore-master \
            chain update synfigstudio-master \
            chain clean_before_do install_release synfigstudio-master-appimage

    local TEMPLATE=`gen_name_template "SynfigStudio" "$SYNFIGSTUDIO_TESTING_TAG" "$PLATFORM" "$ARCH" ".appimage"`
    "$PUBLISH_DIR/publish.sh" \
        "synfigstudio" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-master-appimage/install_release" \
        "*.appimage" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-master-appimage/envdeps_release/version-synfigstudio-master"
}

run_nsis() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update and build synfigstudio for $PLATFORM-$ARCH"
    echo ""
    $SCRIPT chain native update synfigetl-master \
            chain native update synfigcore-master \
            chain update synfigetl-master \
            chain update synfigcore-master \
            chain update synfigstudio-master \
            chain clean_before_do install_release synfigstudio-master-nsis \
            chain clean_before_do install_release synfigstudio-master-portable


    local TEMPLATE=`gen_name_template "SynfigStudio" "$SYNFIGSTUDIO_TESTING_TAG" "$PLATFORM" "$ARCH" ".exe"`
    "$PUBLISH_DIR/publish.sh" \
        "synfigstudio" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-master-nsis/install_release" \
        "*.exe" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-master-nsis/envdeps_release/version-synfigstudio-master"

    local TEMPLATE=`gen_name_template "SynfigStudio" "$SYNFIGSTUDIO_TESTING_TAG" "$PLATFORM" "$ARCH" ".zip"`
    "$PUBLISH_DIR/publish.sh" \
        "synfigstudio" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-master-portable/install_release" \
        "*.zip" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-master-portable/envdeps_release/version-synfigstudio-master"
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
