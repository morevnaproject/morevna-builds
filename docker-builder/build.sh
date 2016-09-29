#!/bin/bash

SCRIPT_FILE=`realpath "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_FILE"`
BASE_DIR=`dirname "$SCRIPT_DIR"`

CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi
export PACKET_BUILD_DIR
mkdir -p $PACKET_BUILD_DIR


docker build -t my/builder $DOCKER_BUILD_OPTIONS "$SCRIPT_DIR"
