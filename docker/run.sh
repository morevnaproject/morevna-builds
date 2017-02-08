#!/bin/bash

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)

if [ "$PLATFORM" -eq "win" ]; then
    "$SCRIPT_DIR/fedora-cross-win/run.sh"
elif [ "$ARCH" -eq "32" ]; then
    "$SCRIPT_DIR/debian-7-32bit/run.sh"
else
    "$SCRIPT_DIR/debian-7-64bit/run.sh"
fi
