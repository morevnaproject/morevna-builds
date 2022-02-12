#!/bin/bash

DIRNAME=`dirname "$0"`
cd $DIRNAME
DIRNAME=`pwd`

sudo docker build -t morevnaproject/builds-64 ./
