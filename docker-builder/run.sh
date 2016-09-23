#!/bin/bash

SCRIPT_FILE=`realpath "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_FILE"`
BASE_DIR=`dirname "$SCRIPT_DIR"`
DATA_DIR="$BASE_DIR/docker-builder-data"

BUILD_DIR=$DATA_DIR/build

$SCRIPT_DIR/stop.sh

docker run -itd \
    --name "builder" \
    -v "$BUILD_DIR:/build" \
    my/builder

