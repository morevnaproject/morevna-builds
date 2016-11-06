#!/bin/bash

SCAN_PATH=$1
DEP=$2

SCAN_PATH=$(cd "$SCAN_PATH"; pwd)

run() {
    local SCAN_PATH=$1
    cd "$SCAN_PATH"
    for FILE in $SCAN_PATH/*; do
        if [ -f "$FILE" ]; then
            if [[ $FILE == *.so* ]] || [[ $FILE == */bin/* ]]; then
                FILE_DEPS=`ldd "$FILE" | grep "$DEP"`
                if [ ! -z "$FILE_DEPS" ]; then
                    echo $FILE
                fi
            fi
        elif [ -d "$FILE" ]; then
            run $FILE
        fi
    done
}

run "$SCAN_PATH"
