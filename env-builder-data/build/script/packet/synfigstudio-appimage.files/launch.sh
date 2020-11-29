#!/bin/bash

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`

# Check if this system have JACK installed
if ! (which jackd &>/dev/null); then
	# No JACK, so disable this functionality.
	# (The bundled libjack won't work correctly anyway).
	export SYNFIG_DISABLE_JACK=1
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${BASE_DIR}/lib.extra/jack"
fi

export USER_CONFIG_DIR=$HOME/.config/synfig

export LD_LIBRARY_PATH="${BASE_DIR}/lib:${BASE_DIR}/lib64:$LD_LIBRARY_PATH"
export XDG_DATA_DIRS="${BASE_DIR}/share:$XDG_DATA_DIRS:/usr/local/share/:/usr/share/"
export XDG_CONFIG_DIRS="$HOME/.config/synfig:$XDG_CONFIG_DIRS"
export XCURSOR_PATH="${BASE_DIR}/share/icons:$XCURSOR_PATH:/usr/local/share/icons:/usr/share/icons"
export GSETTINGS_SCHEMA_DIR="${BASE_DIR}/share/glib-2.0/schemas/"
export QT_XKB_CONFIG_ROOT=$QT_XKB_CONFIG_ROOT:/usr/local/share/X11/xkb:/usr/share/X11/xkb
export FONTCONFIG_PATH="${BASE_DIR}/etc/fonts"

export SYNFIG_ROOT="${BASE_DIR}"
export SYNFIG_GTK_THEME="Adwaita"
export SYNFIG_MODULE_LIST="${BASE_DIR}/etc/synfig_modules.cfg"
export MLT_DATA="${BASE_DIR}/share/mlt/"
export MLT_REPOSITORY="${BASE_DIR}/lib/mlt/"

MAGICK_DIR="$(cd .. && ls -1d "${BASE_DIR}/lib/ImageMagick-"*)"
export MAGICK_CONFIGURE_PATH="${MAGICK_DIR}/config-Q16/"
export MAGICK_CODER_MODULE_PATH="${MAGICK_DIR}/modules-Q16/coders/"
export MAGICK_CODER_FILTER_PATH="${MAGICK_DIR}/modules-Q16/filters/"

# Create install-location-dependent config files for Pango and GDK image loaders
# We have to do this every time because its possible that SYSPREFIX has changed

[ -e "$USER_CONFIG_DIR" ] || mkdir -p "$USER_CONFIG_DIR"

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
	if ! "$BASE_DIR/bin/synfigstudio.wrapper" "$@"; then
		exit 1
	fi
else
	if ! "$BASE_DIR/bin/synfig" "$@"; then
		exit 1
	fi
fi
