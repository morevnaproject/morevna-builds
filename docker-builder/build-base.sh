#!/bin/bash -x

set -e

arch=amd64
suite=wheezy
docker_image="debian:7"

OLDDIR=`pwd`
SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"
BASE_DIR=`dirname "$SCRIPT_DIR"`

CONFIG_FILE="$BASE_DIR/config.sh"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi


if [ -f debian-$suite-$arch.tar.gz ]; then
    docker import - $docker_image < debian-$suite-$arch.tar.gz
else
    echo "File debian-$suite-$arch.tar.gz not found"
    echo "You may try to create it by command ./build-tgz.sh"
    echo "or download it from http://icystar.com/downloads/debian-wheezy-i386.tar.gz"
fi
