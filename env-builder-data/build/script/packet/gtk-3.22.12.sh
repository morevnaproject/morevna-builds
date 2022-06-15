DEPS="epoxy-master rsvg-2.40.16 atk-2.22.0 gdkpixbuf-2.36.0 cairo-1.15.4 pango-1.40.3"
if [ "$PLATFORM" != "linux" ]; then
    DEPS_NATIVE="glib-2.69.3 gtk-3.22.12"
fi

if [ "$PLATFORM" = "linux" ] || [ ! -z "$IS_NATIVE" ]; then
    DEPS="$DEPS atspi2atk-2.22.0"
fi

PK_DIRNAME="gtk+-3.22.12"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/gtk+/3.22/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

if [ "$PLATFORM" = "win" ]; then
    PK_CONFIGURE_OPTIONS="--enable-introspection=no"
fi

pkhook_prebuild() {
    if [ "$PLATFORM" = "win" ]; then
        cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/gtk/gtkwindow.c" "gtk/gtkwindow.c" || return 1
        patch -p1 -i "$FILES_PACKET_DIR/0001-gtkwindow-Don-t-force-enable-CSD-under-Windows.patch" || return 1
    fi
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    local LOCAL_BIN="$BUILD_PACKET_DIR/$PK_DIRNAME/gtk"
    local LOCAL_BIN_NATIVE="$ENVDEPS_NATIVE_PACKET_DIR/bin"
    if [ "$PLATFORM" = "win" ]; then
        [ -f "$LOCAL_BIN/gtk-query-immodules-3.0.exe.orig" ] || \
            mv "$LOCAL_BIN/gtk-query-immodules-3.0.exe" "$LOCAL_BIN/gtk-query-immodules-3.0.orig.exe" || return 1
        cp "$LOCAL_BIN_NATIVE/gtk-query-immodules-3.0" "$LOCAL_BIN/gtk-query-immodules-3.0.exe"
        [ -f "$LOCAL_BIN/gtk-update-icon-cache.exe.orig" ] || \
            mv "$LOCAL_BIN/gtk-update-icon-cache.exe" "$LOCAL_BIN/gtk-update-icon-cache.orig.exe"
        cp "$LOCAL_BIN_NATIVE/gtk-update-icon-cache" "$LOCAL_BIN/gtk-update-icon-cache.exe"
    fi
    make install || return 1
    if [ "$PLATFORM" = "win" ]; then
         cp "$LOCAL_BIN/gtk-query-immodules-3.0.orig.exe" "$INSTALL_PACKET_DIR/bin/gtk-query-immodules-3.0.exe" || return 1 
         cp "$LOCAL_BIN/gtk-update-icon-cache.orig.exe" "$INSTALL_PACKET_DIR/bin/gtk-update-icon-cache.exe" || return 1
    fi
}

