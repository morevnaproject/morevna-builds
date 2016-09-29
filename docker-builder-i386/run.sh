#!/bin/bash

OLDDIR=`pwd`
SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"
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
    --privileged=true \
    -v "$PACKET_BUILD_DIR:/build/packet" \
    -v "$SCRIPT_BUILD_DIR:/build/script" \
    -e PLATFORM=linux-i386 \
    my/builder-i386 \
    setarch i686 /build/script/common/manager.sh "$@"

