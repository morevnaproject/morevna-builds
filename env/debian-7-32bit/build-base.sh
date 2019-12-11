#!/bin/bash -x

set -e

arch=i386
suite=wheezy
chrooter_image="morevnaproject/debian-$arch:$suite"

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`
BASE_DIR=`dirname "$BASE_DIR"`
CONFIG_FILE="$BASE_DIR/config.sh"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi

IMAGE_FILE="$SCRIPT_DIR/debian-$suite-$arch.zip"
if [ ! -f "$IMAGE_FILE" ]; then
    "$SCRIPT_DIR/build-zip.sh"
fi


if [ -f "$IMAGE_FILE" ]; then
    chrooter import - $chrooter_image < "$IMAGE_FILE"
else
    echo "File $IMAGE_FILE not found"
    echo "You may try to create it by command $SCRIPT_DIR/build-zip.sh"
fi
