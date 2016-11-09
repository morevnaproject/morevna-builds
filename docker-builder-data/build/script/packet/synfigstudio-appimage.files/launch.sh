#!/bin/bash

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
BASE_DIR=`dirname "$SCRIPT_DIR"`

# Check if this system have JACK installed
if ( ! ldconfig -p | grep libjack.so >/dev/null ) || ( ! which jackd >/dev/null ) ; then
	# No JACK, so disable this functionality.
	# (The bundled libjack won't work correctly anyway).
	export SYNFIG_DISABLE_JACK=1
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${BASE_DIR}/lib.extra
fi

export USER_CONFIG_DIR=$HOME/.config/synfig

export LD_LIBRARY_PATH="${BASE_DIR}/lib:${BASE_DIR}/lib64:$LD_LIBRARY_PATH"
export XDG_DATA_DIRS="${BASE_DIR}/share:$XDG_DATA_DIRS:/usr/local/share/:/usr/share/"
export XDG_CONFIG_DIRS="$HOME/.config/synfig:$XDG_CONFIG_DIRS"
export GSETTINGS_SCHEMA_DIR="${BASE_DIR}/share/glib-2.0/schemas/"
export QT_XKB_CONFIG_ROOT=$QT_XKB_CONFIG_ROOT:/usr/local/share/X11/xkb:/usr/share/X11/xkb

export SYNFIG_ROOT="${BASE_DIR}"
export SYNFIG_GTK_THEME="Adwaita"
export SYNFIG_MODULE_LIST="${BASE_DIR}/etc/synfig_modules.cfg"
export MLT_DATA="${BASE_DIR}/share/mlt/"
export MLT_REPOSITORY="${BASE_DIR}/lib/mlt/"
export MAGICK_CODER_FILTER_PATH="${BASE_DIR}/lib/ImageMagick-6.9.6/config-Q16/"
export MAGICK_CODER_MODULE_PATH="${BASE_DIR}/lib/ImageMagick-6.9.6/modules-Q16/coders/"
export MAGICK_CONFIGURE_PATH="${BASE_DIR}/lib/ImageMagick-6.9.6/modules-Q16/filters/"

# Create install-location-dependent config files for Pango and GDK image loaders
# We have to do this every time because its possible that SYSPREFIX has changed

[ -e "$USER_CONFIG_DIR" ] || mkdir -p "$USER_CONFIG_DIR"

#sed "s?@ROOTDIR@/modules?${BASE_DIR}/lib/pango/1.6.0/modules?" < $ETC_DIR/pango/pango.modules.in > $USER_CONFIG_DIR/pango/pango.modules
if [ -e ${BASE_DIR}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache.in ]; then
	export GDK_PIXBUF_MODULE_FILE="${USER_CONFIG_DIR}/gdk-pixbuf.loaders"
	sed "s?@ROOTDIR@/loaders?${BASE_DIR}/lib/gdk-pixbuf-2.0/2.10.0/loaders?" < ${BASE_DIR}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache.in > $GDK_PIXBUF_MODULE_FILE
fi

if [ "$1" = "run" ]; then
	"${@:2}"
elif [ -z "$2" ]; then
	"${BASE_DIR}/bin/synfigstudio.wrapper" "$@"
else
	"${BASE_DIR}/bin/synfig" "$@"
fi
