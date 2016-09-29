#!/bin/sh

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`

export LD_LIBRARY_PATH="$BASE_DIR/lib:$BASE_DIR/lib64:$LD_LIBRARY_PATH"
export QT_XKB_CONFIG_ROOT=$QT_XKB_CONFIG_ROOT:/usr/local/share/X11/xkb:/usr/share/X11/xkb

OLDDIR=`pwd`
cd "$BASE_DIR/bin"
./opentoonz "$@"
cd "$OLDDIR"
