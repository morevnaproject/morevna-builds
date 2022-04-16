DEPS="glib-2.69.3 fontconfig-2.12.6"

PK_DIRNAME="harfbuzz-1.3.2"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="https://www.freedesktop.org/software/harfbuzz/release/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="$PK_CONFIGURE_OPTIONS \
 --with-icu=no"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
