#!/bin/bash -x

set -e

arch=i386
suite=wheezy
docker_image="my/debian-$arch:$suite"

if [ -f debian-$suite-$arch.tar.gz ]; then
    docker import - $docker_image < debian-$suite-$arch.tar.gz
else
    echo "File debian-$suite-$arch.tar.gz not found"
    echo "You may try to create it by command ./build-tgz.sh"
    echo "or download it from http://icystar.com/downloads/debian-wheezy-i386.tar.gz"
fi
