#!/bin/bash

SCRIPT_FILE=`realpath "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_FILE"`
BASE_DIR=`dirname "$SCRIPT_DIR"`
DATA_DIR="$BASE_DIR/docker-builder-data"

BUILD_DIR=$DATA_DIR/build

docker stop "builder-i386" || true
docker rm "builder-i386" || true

CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi
export PACKET_BUILD_DIR
mkdir -p $PACKET_BUILD_DIR

docker run -it \
    --name "builder-i386" \
    $DOCKER_RUN_OPTIONS \
    -v "$PACKET_BUILD_DIR:/build/packet" \
    -v "$SCRIPT_BUILD_DIR:/build/script" \
    -e PLATFORM=linux-i386 \
    my/builder-i386 \
    /build/script/common/manager.sh "$@"

