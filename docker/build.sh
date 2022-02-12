#!/bin/bash

DIRNAME=`dirname "$0"`
cd $DIRNAME
DIRNAME=`pwd`

sudo ./linux-64/build.sh
sudo ./linux-32/build.sh
