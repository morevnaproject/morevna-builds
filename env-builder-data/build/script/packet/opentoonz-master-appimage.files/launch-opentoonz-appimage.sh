#!/bin/bash

cd `dirname "$0"`
SCRIPT_DIR=`pwd`
BASE_DIR=`dirname "$SCRIPT_DIR"`

export LD_LIBRARY_PATH="$BASE_DIR/lib:$BASE_DIR/lib/opentoonz:$BASE_DIR/lib/pulseaudio:$BASE_DIR/lib64:$LD_LIBRARY_PATH"
export QT_XKB_CONFIG_ROOT=$QT_XKB_CONFIG_ROOT:/usr/local/share/X11/xkb:/usr/share/X11/xkb
export FONTCONFIG_PATH=/etc/fonts

if [ "$1" = "--appimage-exec" ]; then
	"${@:2}"
else
	"./launch-opentoonz.sh.wrapper" "$@"
fi
