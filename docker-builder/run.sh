#!/bin/bash

SCRIPT_FILE=`realpath "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_FILE"`
BASE_DIR=`dirname "$SCRIPT_DIR"`
DATA_DIR="$BASE_DIR/docker-builder-data"

BUILD_DIR=$DATA_DIR/build

docker stop "builder" || true
docker rm "builder" || true

docker run -it \
    --name "builder" \
    -v "$BUILD_DIR:/build" \
    my/builder \
    /build/script/common/manager.sh "$@"

