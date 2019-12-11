DEPS="jpeg-9b png-1.6.26 tiff-4.0.6 glib-2.50.0"
#DEPS_NATIVE="gobjectintrospection-1.50.0"

PK_DIRNAME="gdk-pixbuf-2.36.0"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/gdk-pixbuf/2.36/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="--enable-relocations=yes"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
