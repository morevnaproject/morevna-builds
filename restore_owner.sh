#!/bin/bash

SCRIPT_FILE=`realpath "$0"`
BASE_DIR=`dirname "$SCRIPT_FILE"`
DATA_DIR="$BASE_DIR/docker-builder-data"

sudo chown -R `id -un`:`id -gn` $DATA_DIR
