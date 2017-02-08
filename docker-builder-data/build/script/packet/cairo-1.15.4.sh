DEPS="png-1.6.26 pixman-0.34.0 fontconfig-2.11.0 glib-2.50.0"

PK_DIRNAME="cairo-1.15.4"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://www.cairographics.org/snapshots/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

if [ "$PLATFORM" = "linux" ] || [ ! -z "$IS_NATIVE" ]; then
    DEPS="$DEPS xcbfull-1.12"
fi
