#!/bin/bash

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`
BASE_DIR=`dirname "$BASE_DIR"`

CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi
mkdir -p $PACKET_BUILD_DIR

if [[ "$(docker images -q morevnaproject/debian-i386:wheezy 2> /dev/null)" == "" ]]; then
	bash ${SCRIPT_DIR}/build-base.sh
fi

docker build -t morevnaproject/build-debian-7-32 $DOCKER_BUILD_OPTIONS "$SCRIPT_DIR"
