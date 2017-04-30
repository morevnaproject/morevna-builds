DEPS="epoxy-master rsvg-2.40.16 atk-2.22.0 gdkpixbuf-2.36.0 cairo-1.15.4 pango-1.40.3"
DEPS_NATIVE="gtk-3.22.12"

PK_DIRNAME="gtk+-3.22.12"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/gtk+/3.22/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

if [ "$PLATFORM" = "linux" ] || [ ! -z "$IS_NATIVE" ]; then
    DEPS="$DEPS atspi2atk-2.22.0"
fi

if [ "$PLATFORM" = "win" ]; then
    PK_CONFIGURE_OPTIONS="--enable-introspection=no"
fi

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    local LOCAL_BIN="$BUILD_PACKET_DIR/$PK_DIRNAME/gtk"
    local LOCAL_BIN_NATIVE="$ENVDEPS_NATIVE_PACKET_DIR/bin"
    if [ "$PLATFORM" = "win" ] && [ ! -f "$LOCAL_BIN/gtk-query-immodules-3.0.exe.orig" ]; then
         mv "$LOCAL_BIN/gtk-query-immodules-3.0.exe" "$LOCAL_BIN/gtk-query-immodules-3.0.exe.orig" || return 1
         cp "$LOCAL_BIN_NATIVE/gtk-query-immodules-3.0" "$LOCAL_BIN/gtk-query-immodules-3.0.exe"
         mv "$LOCAL_BIN/gtk-update-icon-cache.exe" "$LOCAL_BIN/gtk-update-icon-cache.exe.orig"
         cp "$LOCAL_BIN_NATIVE/gtk-update-icon-cache" "$LOCAL_BIN/gtk-update-icon-cache.exe"
    fi
    make install || return 1
    if [ "$PLATFORM" = "win" ]; then
         cp "$LOCAL_BIN/gtk-query-immodules-3.0.exe.orig" "$INSTALL_PACKET_DIR/bin/" || return 1 
         cp "$LOCAL_BIN/gtk-update-icon-cache.exe.orig" "$INSTALL_PACKET_DIR/bin/" || return 1
    fi
}

