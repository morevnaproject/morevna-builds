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

chrooter build -t morevnaproject/build-debian-7-32 --privileged=true --buildarch=i686 $CHROOTER_BUILD_OPTIONS "$SCRIPT_DIR"
