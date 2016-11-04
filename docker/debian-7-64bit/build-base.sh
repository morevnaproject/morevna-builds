#!/bin/bash -x

set -e

arch=amd64
suite=wheezy
docker_image="debian:7"

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`
BASE_DIR=`dirname "$BASE_DIR"`
CONFIG_FILE="$BASE_DIR/config.sh"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi

IMAGE_FILE="$SCRIPT_DIR/debian-$suite-$arch.tar.gz"
if [ ! -f "$IMAGE_FILE" ]; then
    "$SCRIPT_DIR/build-tgz.sh"
fi


if [ -f "$IMAGE_FILE" ]; then
    docker import - $docker_image < "$IMAGE_FILE"
else
    echo "File $IMAGE_FILE not found"
    echo "You may try to create it by command $SCRIPT_DIR/build-tgz.sh"
fi
