#!/bin/bash

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`
BASE_DIR=`dirname "$BASE_DIR"`
DATA_DIR="$BASE_DIR/docker-builder-data"
BUILD_DIR=$DATA_DIR/build
CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi
mkdir -p $PACKET_BUILD_DIR

export NATIVE_PLATFORM=debian
if [ -z "$PLATFORM" ]; then
    export PLATFORM=linux
fi
if [ -z "$ARCH" ]; then
    export ARCH=64
fi
if [ -z "$TASK" ]; then
    export TASK=builder-$NATIVE_PLATFORM
fi
export INSTANCE=$TASK-$PLATFORM$ARCH

docker stop "$INSTANCE" || true
docker rm "$INSTANCE" || true
docker run -it \
    --name "$INSTANCE" \
    --privileged=true \
    $DOCKER_RUN_OPTIONS \
    -v "$PACKET_BUILD_DIR:/build/packet" \
    -v "$SCRIPT_BUILD_DIR:/build/script" \
    -e NATIVE_PLATFORM="$NATIVE_PLATFORM" \
    -e NATIVE_ARCH="$NATIVE_ARCH" \
    -e PLATFORM="$PLATFORM" \
    -e ARCH="$ARCH" \
    -e THREADS="$THREADS" \
    morevnaproject/builder-64:debian7 \
    /build/script/common/manager.sh "$@"

