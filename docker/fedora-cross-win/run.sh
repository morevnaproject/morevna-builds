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

docker stop "builder" || true
docker rm "builder" || true

if [ -z "$ARCH" ];then
    export ARCH=64
fi

if [ -z "$PLATFORM" ];then
    export PLATFORM=win-$ARCH
fi


docker run -it \
    --name "builder" \
    --privileged=true \
    $DOCKER_RUN_OPTIONS \
    -v "$PACKET_BUILD_DIR:/build/packet" \
    -v "$SCRIPT_BUILD_DIR:/build/script" \
    -e ARCH="$ARCH" \
    -e PLATFORM="$PLATFORM" \
    morevna/build-fedora-cross-win \
    /build/script/common/manager.sh "$@"

