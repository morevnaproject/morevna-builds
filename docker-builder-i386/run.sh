#!/bin/bash

SCRIPT_FILE=`realpath "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_FILE"`
BASE_DIR=`dirname "$SCRIPT_DIR"`
DATA_DIR="$BASE_DIR/docker-builder-data"

BUILD_DIR=$DATA_DIR/build

docker stop "builder-i386" || true
docker rm "builder-i386" || true

docker run -it \
    --name "builder-i386" \
    -v "$BUILD_DIR:/build" \
    -e PLATFORM=linux-i386 \
    my/builder-i386 \
    /build/script/common/manager.sh "$@"

