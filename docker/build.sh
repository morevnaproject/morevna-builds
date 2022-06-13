#!/bin/bash

DIRNAME=`dirname "$0"`
cd $DIRNAME
DIRNAME=`pwd`

./linux-64/build.sh
./linux-32/build.sh
./mingw/build.sh
