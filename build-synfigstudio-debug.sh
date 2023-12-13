#!/bin/bash

set -e

BASE_DIR=$(cd `dirname "$0"`; pwd)
DATA_DIR="$BASE_DIR/env-builder-data"
BUILD_DIR=$DATA_DIR/build
PUBLISH_DIR=$BASE_DIR/publish
CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
SYNFIGSTUDIO_DEBUG_TAG="debug"

source "$BASE_DIR/gen-name.sh"

if [ -f $CONFIG_FILE ]; then
    source $CONFIG_FILE
fi

SCRIPT="$BASE_DIR/run.sh"

run_appimage() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update and build synfigstudio-debug for $PLATFORM-$ARCH"
    echo ""
    $SCRIPT chain native update synfigetl-debug \
            chain native update synfigcore-debug \
            chain update synfigetl-debug \
            chain update synfigcore-debug \
            chain update synfigstudio-debug \
            chain clean_before_do install_release synfigstudio-debugappimage

    local TEMPLATE=`gen_name_template "SynfigStudio" "$SYNFIGSTUDIO_DEBUG_TAG" "$PLATFORM" "$ARCH" ".appimage"`
    "$PUBLISH_DIR/publish.sh" \
        "synfigstudio-debug" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-debugappimage/install_release" \
        "*.appimage" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-debugappimage/envdeps_release/version-synfigstudio-debug"
}

run_nsis() {
    export PLATFORM="$1"
    export ARCH="$2"

    echo ""
    echo "Update synfigstudio-debug for $PLATFORM-$ARCH"
    echo ""
    PLATFORM=win ARCH=32 $SCRIPT clean_before_do env zlib-1.2.13 # for NSIS
    $SCRIPT chain native update synfigetl-debug \
            chain native update synfigcore-debug \
            chain update synfigetl-debug \
            chain update synfigcore-debug \
            chain update synfigstudio-debug \
            chain clean_before_do install_release synfigstudio-debugnsis \
            chain clean_before_do install_release synfigstudio-debugportable

    local TEMPLATE=`gen_name_template "SynfigStudio" "$SYNFIGSTUDIO_DEBUG_TAG" "$PLATFORM" "$ARCH" ".exe"`
    "$PUBLISH_DIR/publish.sh" \
        "synfigstudio-debug" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-debugnsis/install_release" \
        "*.exe" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-debugnsis/envdeps_release/version-synfigstudio-debug"

    local TEMPLATE=`gen_name_template "SynfigStudio" "$SYNFIGSTUDIO_DEBUG_TAG" "$PLATFORM" "$ARCH" ".zip"`
    "$PUBLISH_DIR/publish.sh" \
        "synfigstudio-debug" \
        "$TEMPLATE" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-debugportable/install_release" \
        "*.zip" \
        "$PACKET_BUILD_DIR/$PLATFORM-$ARCH/synfigstudio-debugportable/envdeps_release/version-synfigstudio-debug"
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
