#!/bin/bash

DIRNAME=`dirname "$0"`
cd $DIRNAME
DIRNAME=`pwd`

docker build -t morevnaproject/builds-mingw ./
