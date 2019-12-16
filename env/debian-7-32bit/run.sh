#!/bin/bash

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`
BASE_DIR=`dirname "$BASE_DIR"`
DATA_DIR="$BASE_DIR/env-builder-data"
BUILD_DIR=$DATA_DIR/build
CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
if [ -f $CONFIG_FILE ]; then
    source $CONFIG_FILE
fi
mkdir -p $PACKET_BUILD_DIR

export NATIVE_PLATFORM=debian
export NATIVE_ARCH=32
if [ -z "$PLATFORM" ]; then
    export PLATFORM=linux
fi
if [ -z "$ARCH" ]; then
    export ARCH=$NATIVE_ARCH
fi
export INSTANCE=builder-$NATIVE_PLATFORM-$NATIVE_ARCH

chrooter stop "$INSTANCE" || true
chrooter rm "$INSTANCE" || true
chrooter run -it \
    --name "$INSTANCE" \
    --privileged=true \
    $CHROOTER_RUN_OPTIONS \
    -v "$PACKET_BUILD_DIR:/build/packet" \
    -v "$SCRIPT_BUILD_DIR:/build/script" \
    -e NATIVE_PLATFORM="$NATIVE_PLATFORM" \
    -e NATIVE_ARCH="$NATIVE_ARCH" \
    -e PLATFORM="$PLATFORM" \
    -e ARCH="$ARCH" \
    -e THREADS="$THREADS" \
    morevnaproject/build-debian-7-32 \
    setarch i686 /build/script/common/manager.sh "$@"

