DEPS=""
DEPS_NATIVE="glib-2.50.0"

PK_DIRNAME="glib-2.50.0"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/glib/2.50/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="--with-pcre=internal"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
