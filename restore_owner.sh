#!/bin/bash

OLDDIR=`pwd`
BASE_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"
DATA_DIR="$BASE_DIR/docker-builder-data"

CONFIG_FILE="$BASE_DIR/config.sh"
PACKET_BUILD_DIR="$DATA_DIR/build/packet"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi

sudo chown -R `id -un`:`id -gn` $PACKET_BUILD_DIR
sudo chown -R `id -un`:`id -gn` "$BASE_DIR/docker/image"
