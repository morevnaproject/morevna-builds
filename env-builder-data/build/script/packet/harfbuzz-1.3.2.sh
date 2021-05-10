DEPS="glib-2.50.0"
if [ "$PLATFORM" = "linux" ]; then
    DEPS_NATIVE="$DEPS_NATIVE fontconfig-2.11.0"
else
    DEPS="$DEPS fontconfig-2.11.0"
fi

PK_DIRNAME="harfbuzz-1.3.2"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="https://www.freedesktop.org/software/harfbuzz/release/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
