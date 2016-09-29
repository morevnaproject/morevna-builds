#!/bin/bash

OLDDIR=`pwd`
BASE_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"
DATA_DIR="$BASE_DIR/docker-builder-data"
BUILD_DIR=$DATA_DIR/build

CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi
export PACKET_BUILD_DIR
mkdir -p $PACKET_BUILD_DIR

$SCRIPT_BUILD_DIR/common/manager.sh "$@"
