# GTK packets:
#   gtkmm, atkmm, cairomm, pangomm, glibmm, sigcpp
#   gtk
#   adwaitaicontheme gnomethemesstandard

DEPS="gtk-3.22.30 atkmm-2.24.2 cairomm-1.12.0 pangomm-2.40.1 adwaitaicontheme-3.24.0 gnomethemesstandard-3.22.3"

PK_DIRNAME="gtkmm-3.22.2"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="https://download.gnome.org/sources/gtkmm/3.22/$PK_ARCHIVE"
PK_LICENSE_FILES="AUTHORS COPYING COPYING.tools"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
