DEPS="harfbuzz-1.3.2 glib-2.50.0 cairo-1.15.4"
#DEPS_NATIVE="gobjectintrospection-1.50.0"
if [ "$PLATFORM" = "linux" ]; then
    DEPS_NATIVE="$DEPS_NATIVE fontconfig-2.11.0"
else
    DEPS="$DEPS fontconfig-2.11.0"
fi

PK_DIRNAME="pango-1.40.3"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/pango/1.40/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
