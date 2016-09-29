#!/bin/bash

OLDDIR=`pwd`
SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"
BASE_DIR=`dirname "$SCRIPT_DIR"`
DATA_DIR="$BASE_DIR/docker-builder-data"

BUILD_DIR=$DATA_DIR/build

docker stop "builder" || true
docker rm "builder" || true

CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi
export PACKET_BUILD_DIR
mkdir -p $PACKET_BUILD_DIR

docker run -it \
    --name "builder" \
    --privileged=true \
    $DOCKER_RUN_OPTIONS \
    -v "$PACKET_BUILD_DIR:/build/packet" \
    -v "$SCRIPT_BUILD_DIR:/build/script" \
    my/builder \
    /build/script/common/manager.sh "$@"

