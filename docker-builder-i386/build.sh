#!/bin/bash

SCRIPT_FILE=`realpath "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_FILE"`

docker build -t my/builder-i386 "$SCRIPT_DIR"
