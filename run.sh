#!/bin/bash

# remove:
# env/*

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
#BASE_DIR=`dirname "$SCRIPT_DIR"`
#BASE_DIR=`dirname "$BASE_DIR"`
DATA_DIR="$SCRIPT_DIR/env-builder-data"
BUILD_DIR=$DATA_DIR/build
CONFIG_FILE="$SCRIPT_DIR/config.sh"
PACKET_BUILD_DIR="$BUILD_DIR/packet"
SCRIPT_BUILD_DIR="$BUILD_DIR/script"


if [ -z "$PLATFORM" ]; then
    PLATFORM="linux"
fi
if [ -z "$ARCH" ]; then
    ARCH="64"
fi

if [[ "$PLATFORM" == "linux" ]] && [[ "$ARCH" == "32" ]]; then
    # see https://github.com/multiarch/crossbuild/issues/7
    #DOCKER_IMAGE="kohanyirobert/crossbuild-i386-linux-gnu"
    DOCKER_IMAGE="morevnaproject/builds-32"
    # ATTENTION! The NATIVE_PLATFORM should not be equal to PLATFORM ("linux"), otherwise bad things happen.
    NATIVE_PLATFORM="debian"
    NATIVE_ARCH="32"
    SETARCH="setarch i686"
else
    #DOCKER_IMAGE="multiarch/crossbuild"
    # docker build -t morevnaproject/builds-64 .
    DOCKER_IMAGE="morevnaproject/builds-64"
    # ATTENTION! The NATIVE_PLATFORM should not be equal to PLATFORM ("linux"), otherwise bad things happen.
    NATIVE_PLATFORM="debian"
    NATIVE_ARCH="64"
    SETARCH=""
fi

$SCRIPT_DIR/docker/linux-$NATIVE_ARCH/build.sh

# FUSE required for AppImage
docker run --rm \
    --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined \
    -v $(pwd):/workdir \
    -v "$PACKET_BUILD_DIR:/build/packet" \
    -v "$SCRIPT_BUILD_DIR:/build/script" \
    --env PLATFORM="$PLATFORM" \
    --env ARCH="$ARCH" \
    --env NATIVE_PLATFORM="$NATIVE_PLATFORM" \
    --env NATIVE_ARCH="$NATIVE_ARCH" \
    ${DOCKER_IMAGE} \
    ${SETARCH} /build/script/common/manager.sh "$@"
