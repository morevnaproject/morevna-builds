#!/bin/bash

set -e


BASE_DIR=$(cd `dirname "$0"`; pwd)
CONFIG_FILE="$BASE_DIR/config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

cd $BASE_DIR
git fetch morevnaproject
git reset --hard morevnaproject/master

LOG_FILE="$BASE_DIR/log/background.log"

echo "-------------------------------" >> "$LOG_FILE"
date                                   >> "$LOG_FILE"
echo background.sh "$@"                >> "$LOG_FILE"
echo "-------------------------------" >> "$LOG_FILE"

if [ "$1" == "-q" ]; then
    export EMAIL_SUCCESS=
    nohup "$BASE_DIR/withemail.sh" ${@:2} &>> "$LOG_FILE" &
else
    nohup "$BASE_DIR/withemail.sh" $@ &>> "$LOG_FILE" &
fi

echo "task now in backround"
