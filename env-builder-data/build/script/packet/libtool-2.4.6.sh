DEPS=""

PK_DIRNAME="libtool-2.4.6"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://ftpmirror.gnu.org/libtool/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkhook_postinstall() {
    patch "share/aclocal/libtool.m4" "$FILES_PACKET_DIR/libtool.m4.patch" || return 1
}
