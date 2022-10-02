DEPS="harfbuzz-1.3.2 glib-2.69.3 cairo-1.15.4 fontconfig-2.12.6"
#DEPS_NATIVE="gobjectintrospection-1.50.0"

PK_DIRNAME="pango-1.40.3"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/pango/1.40/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkhook_prebuild() {
    if [ "$PLATFORM" = "win" ]; then
        cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/pango/Makefile.am" "pango/Makefile.am" || return 1
        cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/pangowin32.pc.in" "pangowin32.pc.in" || return 1
        patch -p1 -i "$FILES_PACKET_DIR/win7-compatibility.patch" || return 1
        autoreconf -fi
    fi
}
