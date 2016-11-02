#!/bin/bash

PREFIX=`dirname "$0"`
cd $PREFIX
docker build -t morevna/build-fedora-cross-win .
