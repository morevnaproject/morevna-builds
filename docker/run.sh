#!/bin/bash

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`
DATA_DIR="$BASE_DIR/docker-builder-data"

BUILD_DIR=${DATA_DIR}/build

CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi
export PACKET_BUILD_DIR
mkdir -p $PACKET_BUILD_DIR

if [ -z "${IMAGE}" ];then
    export IMAGE=fedora-cross-win
fi

if [ -z "$TASK" ];then
    export TASK=synfig-win
fi

if [ -z "$ARCH" ];then
    export ARCH=64
fi



export INSTANCE="build-${TASK}-${ARCH}"

# TODO: Automatically build image if not found

docker stop "${INSTANCE}" || true
docker rm "${INSTANCE}" || true


docker run -it \
    --name "${INSTANCE}" \
    --privileged=true \
    $DOCKER_RUN_OPTIONS \
    -v "${PACKET_BUILD_DIR}:/build/packet" \
    -v "${SCRIPT_BUILD_DIR}:/build/script" \
    morevna/${IMAGE} \
    "$@"
