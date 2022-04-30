DEPS="gtk-2.20.1"

PK_DIRNAME="gtkimageview-1.6.4+dfsg"
PK_ARCHIVE="gtkimageview_1.6.4+dfsg.orig.tar.gz"
PK_URL="https://deb.debian.org/debian/pool/main/g/gtkimageview/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh



pkhook_prebuild() {
    cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/src/gtkimagenav.c" "src/gtkimagenav.c" || return 1
    patch -p1 -i "$FILES_PACKET_DIR/misleading-indentation.patch" || return 1
}

