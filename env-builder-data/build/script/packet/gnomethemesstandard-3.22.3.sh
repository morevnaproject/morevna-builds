DEPS="rsvg-2.40.16 gtk-3.22.30"

PK_DIRNAME="gnome-themes-standard-3.22.3"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/gnome-themes-standard/3.22/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="--disable-gtk2-engine"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
