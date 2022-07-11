DEPS="rsvg-2.40.16 gtk-3.22.30"

PK_DIRNAME="adwaita-icon-theme-3.24.0"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/adwaita-icon-theme/3.24/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="--disable-gtk2-engine"
PK_LICENSE_FILES="AUTHORS COPYING COPYING_CCBYSA3 COPYING_LGPL"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkhook_postinstall() {
    if [ "$PLATFORM" = "win" ]; then
	# Fix color picker cursor issue
	# https://github.com/synfig/synfig/issues/536
	cd "$INSTALL_PACKET_DIR"
        cp share/icons/Adwaita/cursors/cross.cur share/icons/Adwaita/cursors/color-picker.cur
    fi
}
