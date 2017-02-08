DEPS="epoxy-master rsvg-2.40.16 atk-2.22.0 gdkpixbuf-2.36.0 cairo-1.15.4 pango-1.40.3"

PK_DIRNAME="gtk+-3.14.14"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/gtk+/3.14/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

if [ "$PLATFORM" = "linux" ] || [ ! -z "$IS_NATIVE" ]; then
    DEPS="$DEPS atspi2atk-2.22.0"
fi

