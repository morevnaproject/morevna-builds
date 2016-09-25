#!/bin/bash

SCRIPT_FILE=`realpath "$0"`
BASE_DIR=`dirname "$SCRIPT_FILE"`
DATA_DIR="$BASE_DIR/docker-builder-data"

BUILD_DIR=$DATA_DIR/build

$BUILD_DIR/script/common/manager.sh "$@"
