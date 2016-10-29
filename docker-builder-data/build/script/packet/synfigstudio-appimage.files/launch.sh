#!/bin/bash

OLDDIR=`pwd`
SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"
BASE_DIR=`dirname "$SCRIPT_DIR"`

export LD_LIBRARY_PATH="$BASE_DIR/lib:$BASE_DIR/lib64:$LD_LIBRARY_PATH"
export XDG_DATA_DIRS="$BASE_DIR/share:$XDG_DATA_DIRS"
export QT_XKB_CONFIG_ROOT=$QT_XKB_CONFIG_ROOT:/usr/local/share/X11/xkb:/usr/share/X11/xkb

export SYNFIG_ROOT="$BASE_DIR"
export SYNFIG_MODULE_LIST="$BASE_DIR/etc/synfig_modules.cfg"
export MLT_DATA="$BASE_DIR/share/mlt/"
export MLT_REPOSITORY="$BASE_DIR/lib/mlt/"
export MAGICK_CODER_FILTER_PATH="$BASE_DIR/lib/ImageMagick-6.9.6/config-Q16/"
export MAGICK_CODER_MODULE_PATH="$BASE_DIR/lib/ImageMagick-6.9.6/modules-Q16/coders/"
export MAGICK_CONFIGURE_PATH="$BASE_DIR/lib/ImageMagick-6.9.6/modules-Q16/filters/"

cd "$BASE_DIR/bin"
if [ "$1" = "run" ]; then
	"${@:2}" || (cd "$OLDDIR" && return $?)
elif [ -z "$2" ]; then
	"$BASE_DIR/bin/synfigstudio.wrapper" "$@" || (cd "$OLDDIR" && return $?) 
else
	"$BASE_DIR/bin/synfig" "$@" || (cd "$OLDDIR" && return $?)
fi
cd "$OLDDIR"
