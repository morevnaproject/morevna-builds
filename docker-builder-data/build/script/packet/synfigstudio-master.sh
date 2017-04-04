#   jasper       - from gdkpixbuf | jpeg, freeglut
#   atspi2       - from atspi2atk | glib
#   gobjectintrospection - from gdkpixbuf | glib

# 	atk          - from gtk       | glib
#   atspi2atk    - from gtk       | atk, atspi2
# 	gdkpixbuf    - from gtk       | jpeg, png, tiff, jasper, glib, gobjectintrospection
#   rsvg         - from gtk,adwa..| xml, gdkpixbuf, cairo, pango

# 	gtk          - from gtkmm     | epoxy, rsvg, atk, atspi2atk, gdkpixbuf, cairo, pango
#   atkmm        - from gtkmm     | atk, glibmm
#   cairomm      - from gtkmm     | cairo, sigcpp
#   pangomm      - from gtkmm     | pango, glibmm, cairomm

#   synfigcore                    | -
#   gtkmm                         | gtk, atkmm, cairomm, pangomm
#   adwaitaicons                  | gtk, rsvg
#   gnomethemes                   | gtk, rsvg

DEPS="synfigcore-master gtkmm-3.22.0 adwaitaicontheme-3.22.0 gnomethemesstandard-3.22.2"
DEPS_NATIVE="libtool-2.4.6 synfigcore-master"

PK_DIRNAME="synfig"
PK_URL="https://github.com/synfig/$PK_DIRNAME.git"
PK_GIT_OPTIONS="--branch testing"
PK_CPPFLAGS="-std=c++11"
PK_LICENSE_FILES="synfig-studio/AUTHORS synfig-studio/README"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/synfig-studio" || return 1
    if ! check_packet_function $NAME build.configure; then
        ./bootstrap.sh || return 1
        ./configure \
         --host=$HOST \
         --prefix=$INSTALL_PACKET_DIR \
         --sysconfdir=$INSTALL_PACKET_DIR/etc \
        || return 1
        set_done $NAME build.configure
    fi
    make -j${THREADS} || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/synfig-studio"
    if ! make install; then
        return 1
    fi
    cd "$INSTALL_PACKET_DIR"
    mv "share/pixmaps/synfigstudio/"* "share/pixmaps/"
}
