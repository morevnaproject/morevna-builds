DEPS=""

PK_DIRNAME="adwaita-icon-theme-3.22.0"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/adwaita-icon-theme/3.22/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="--disable-gtk2-engine"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
