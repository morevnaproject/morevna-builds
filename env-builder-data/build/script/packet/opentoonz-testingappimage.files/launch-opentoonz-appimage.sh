#!/bin/bash

OLDDIR=`pwd`
cd `dirname "$0"`
SCRIPT_DIR=`pwd`
BASE_DIR=`dirname "$SCRIPT_DIR"`

export LD_LIBRARY_PATH="$BASE_DIR/lib:$BASE_DIR/lib/opentoonz:$BASE_DIR/lib/pulseaudio:$BASE_DIR/lib64:$LD_LIBRARY_PATH"
export QT_XKB_CONFIG_ROOT=$QT_XKB_CONFIG_ROOT:/usr/local/share/X11/xkb:/usr/share/X11/xkb

if [ "$1" = "--appimage-exec" ]; then
	if ! "${@:2}"; then
		cd "$OLDDIR"
		exit 1
	fi
else
	if ! "./launch-opentoonz.sh.wrapper" "$@"; then
		cd "$OLDDIR"
		exit 1
	fi
fi
cd "$OLDDIR"
