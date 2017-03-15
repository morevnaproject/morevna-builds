#!/bin/bash

set -e

PUBLISH_DIR=$(cd `dirname "$0"`; pwd)

publish_file() {
    local NAME="$1"
    local TEMPLATE="$2" # Xxxxx-%VERSION%-%DATE%-%COMMIT%-xxxxx.xxx"
    local PATH="$3"
    local MASK="$4"
    local VERSION_FILE="$5"

    local FILE=`ls "$PATH/"$MASK`

    local VERSION=`cat "$VERSION_FILE" | cut -d'-' -f 1`
    local COMMIT=`cat "$VERSION_FILE" | cut -d'-' -f 2-`
    COMMIT="${COMMIT:0:5}"
    local DATE=`date -u +%Y.%m.%d`
    if [ -z "$COMMIT" ]; then
        echo "Cannot find version, pheraps package not ready. Cancel."
        return 1
    fi

    local CHECK_MASK=` \
        echo "$TEMPLATE" \
        | sed "s|%VERSION%|$VERSION|g" \
        | sed "s|%DATE%|*|g" \
        | sed "s|%COMMIT%|$COMMIT|g" `
    local CHECK=`ls "$PUBLISH_DIR/"$CHECK_MASK`
    if [ -z "$CHECK" ]; then
        local TARGET_NAME=` \
            echo "$TEMPLATE" \
            | sed "s|%VERSION%|$VERSION|g" \
            | sed "s|%DATE%|$DATE|g" \
            | sed "s|%COMMIT%|$COMMIT|g" `
        local TARGET="$PUBLISH_DIR/$TARGET_NAME"

        echo "Publish new version $VERSION-$COMMIT ($TARGET_NAME)"
        `rm -f "$PUBLISH_DIR/"$CHECK_MASK`
        cp "$FILE" "$TARGET"
        if [ -f "$PUBLISH_DIR/publish-$NAME.sh" ]; then
            echo "Call publish-$NAME.sh"
            "$PUBLISH_DIR/publish-$NAME.sh" "$TARGET"
        fi
    else
        echo "Version $VERSION-$COMMIT already published ($CHECK)"
    fi
}

publish $@
