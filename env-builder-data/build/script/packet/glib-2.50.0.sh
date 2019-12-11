DEPS="zlib-1.2.11 ffi-3.2.1"
DEPS_NATIVE="glib-2.50.0"

PK_DIRNAME="glib-2.50.0"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/glib/2.50/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="--with-pcre=internal --disable-compile-warnings"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh


pkhook_prebuild() {
    if [ "$PLATFORM" = "win" ]; then
        cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/glib/gstrfuncs.c" "glib" || return 1
        patch "glib/gstrfuncs.c" "$FILES_PACKET_DIR/gstrfuncs.c.patch" || return 1
    fi
}
