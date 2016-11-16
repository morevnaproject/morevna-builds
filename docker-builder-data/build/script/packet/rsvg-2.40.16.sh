DEPS="xml-2.9.4 gdkpixbuf-2.36.0 cairo-1.14.6 pango-1.40.3"

PK_DIRNAME="librsvg-2.40.16"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/librsvg/2.40/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkbuild-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    make install || return 1
    local GDK_API_VERSION=`ls $ENVDEPS_PACKET_DIR/lib/gdk-pixbuf-2.0/ | grep 2`
    if [ -z "$GDK_API_VERSION" ]; then
        return 1
    fi
    local GDK_LOADERS="$INSTALL_PACKET_DIR/lib/gdk-pixbuf-2.0/$GDK_API_VERSION/loaders"
    mkdir -p "$GDK_LOADERS" || return 1
    cp --remove-destination "$BUILD_PACKET_DIR/$PK_DIRNAME/gdk-pixbuf-loader/.libs/libpixbufloader-svg.so" "$GDK_LOADERS/" || return 1
}
