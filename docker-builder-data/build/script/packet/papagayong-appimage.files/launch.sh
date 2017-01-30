#!/bin/bash

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`

export LD_LIBRARY_PATH="${BASE_DIR}/lib:${BASE_DIR}/lib64:$LD_LIBRARY_PATH"
export XDG_DATA_DIRS="${BASE_DIR}/share:$XDG_DATA_DIRS:/usr/local/share/:/usr/share/"
export GSETTINGS_SCHEMA_DIR="${BASE_DIR}/share/glib-2.0/schemas/"
export PYTHONHOME=$BASE_DIR

#sed "s?@ROOTDIR@/modules?${BASE_DIR}/lib/pango/1.6.0/modules?" < $ETC_DIR/pango/pango.modules.in > $USER_CONFIG_DIR/pango/pango.modules
if [ -e ${BASE_DIR}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache.in ]; then
	export GDK_PIXBUF_MODULE_FILE="${USER_CONFIG_DIR}/gdk-pixbuf.loaders"
	sed "s?@ROOTDIR@/loaders?${BASE_DIR}/lib/gdk-pixbuf-2.0/2.10.0/loaders?" < ${BASE_DIR}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache.in > $GDK_PIXBUF_MODULE_FILE
fi

export APPIMAGE_ROOT="$BASE_DIR"
if [ ! -z "$APPIMAGE_WORKDIR" ]; then
	if ! cd "$APPIMAGE_WORKDIR"; then
		echo "Cannot change directory to \"$APPIMAGE_WORKDIR\" (APPIMAGE_WORKDIR)"
		exit 1
	fi
fi

if [ "$1" = "--appimage-exec" ]; then
	if ! "${@:2}"; then
		exit 1
	fi
elif [ -z "$2" ]; then
	if ! "$BASE_DIR/bin/papagayong.wrapper" "$@"; then
		exit 1
	fi
elif [ "$1" -eq "--remove-appimage-desktop-integration" ]; then
	if ! "$BASE_DIR/bin/papagayong.wrapper" "$@"; then
		exit 1
	fi
else
	if ! "$BASE_DIR/bin/papagayong" "$@"; then
		exit 1
	fi
fi
