#!/bin/bash
#

if [ -z "$1" ]; then
    echo "ERROR: No binary specified."
    exit 1
fi

SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPTDIR}/../../packet/"
PACKETDIR="`pwd`/"

BINARY="$1"
BINARY_DIR=`dirname $BINARY`
if [[ "$BINARY_DIR" == "." ]] && [ ! -f ./$BINARY ]; then
    if ( which $BINARY ); then
        BINARY=`which $BINARY`
        BINARY_DIR=`dirname $BINARY`
    fi
fi
cd "$BINARY_DIR"
BINARY_DIR=`pwd`

# Now replace
LOCALPATH="${BINARY_DIR/"$PACKETDIR"/}"
LOCALPATH="${LOCALPATH#*/}"

BINARY_FILE=`basename ${BINARY%.exe}`
NATIVE_BINARY="${PACKETDIR}debian-64-native/${LOCALPATH}/${BINARY_FILE}"
#echo $NATIVE_BINARY "${@:2}"
if [ ! -f "$NATIVE_BINARY" ]; then
    exit 0
else
    "$NATIVE_BINARY" "${@:2}"
fi

