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

DEPS="synfigcore-master gtkmm-3.22.0"
DEPS_NATIVE="libtool-2.4.6"

if [ "$PLATFORM" = "linux" ]; then
    DEPS="$DEPS jack-0.125.0"
else
    DEPS_NATIVE="synfigcore-master $DEPS_NATIVE"
fi

PK_DIRNAME="synfig"
PK_URL="https://github.com/synfig/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="origin/testing"
PK_CPPFLAGS="-std=c++11"

# put COPYING to front for license agreement page of NSIS installer
PK_LICENSE_FILES="synfig-studio/COPYING synfig-studio/README synfig-studio/AUTHORS"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkhook_version() {
    cat "$PK_DIRNAME/synfig-studio/configure.ac" \
    | egrep "AC_INIT\(\[Synfig Studio\],"| sed "s|.*Studio\],\[||" | sed "s|\],\[.*||" \
    || return 1
}

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/synfig-studio" || return 1
    if ! check_packet_function $NAME build.configure; then
        ./bootstrap.sh || return 1
        ./configure \
         --host=$HOST \
         --prefix=$INSTALL_PACKET_DIR \
         --sysconfdir=$INSTALL_PACKET_DIR/etc \
         $PK_CONFIGURE_OPTIONS \
         || return 1
        set_done $NAME build.configure
    fi
    make -j${THREADS} || make || make || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/synfig-studio"
    if ! make install; then
        return 1
    fi

    cd "$INSTALL_PACKET_DIR"

    # configuration
    if [ "$PLATFORM" = "win" ]; then
        mv "share/pixmaps/synfigstudio/"* "share/pixmaps/"
        mkdir -p "share/gtk-3.0"
        cp "$BUILD_PACKET_DIR/$PK_DIRNAME/autobuild/gtk-3.0/settings.ini" "share/gtk-3.0/" || return 1
        mkdir -p "lib/gdk-pixbuf-2.0/2.10.0"
        cp "$FILES_PACKET_DIR/loaders.cache" "lib/gdk-pixbuf-2.0/2.10.0/"  || return 1
    fi

    # add examples
    cp -r "$BUILD_PACKET_DIR/$PK_DIRNAME/synfig-core/examples" "$INSTALL_PACKET_DIR/share/synfig/" || return 1

    # copy system libraries
    if [ "$PLATFORM" = "win" ]; then
        local TARGET="$INSTALL_PACKET_DIR/bin/"

        #local LOCAL_DIR="/usr/local/$HOST/sys-root/$HOST/lib/"
        local LOCAL_DIR="/usr/lib/gcc/$HOST/6.3-posix/"
        cp "$LOCAL_DIR"/libgcc*.dll        "$TARGET" || return 1
        cp "$LOCAL_DIR"/libstdc*.dll       "$TARGET" || return 1
        cp "$LOCAL_DIR"/libquadmath*.dll   "$TARGET" || return 1
        cp "$LOCAL_DIR"/libgfortran*.dll   "$TARGET" || return 1

        #local LOCAL_DIR="/usr/local/$HOST/sys-root/bin/"
        local LOCAL_DIR="/usr/$HOST/lib/"
        cp "$LOCAL_DIR"/libwinpthread*.dll "$TARGET" || return 1
        
        local LOCAL_DIR="/usr/$HOST/bin/"
        cp "$LOCAL_DIR"/libgettextlib*.dll "$TARGET" || return 1
        cp "$LOCAL_DIR"/libintl*.dll       "$TARGET" || return 1
        cp "$LOCAL_DIR"/libiconv*.dll      "$TARGET" || return 1
    else
        local TARGET="$INSTALL_PACKET_DIR/lib/"
        copy_system_gcc_libs               "$TARGET" || return 1
        copy_system_lib libudev            "$TARGET" || return 1
        copy_system_lib libdb              "$TARGET" || return 1
        copy_system_lib libpcre            "$TARGET" || return 1
        copy_system_lib libdirect          "$TARGET" || return 1
        copy_system_lib libfusion          "$TARGET" || return 1
        copy_system_lib libbz2             "$TARGET" || return 1
        copy_system_lib libselinux         "$TARGET" || return 1
    fi
}

pkhook_postlicense() {
    local TARGET="$LICENSE_PACKET_DIR"
    if [ "$PLATFORM" = "win" ]; then
        local LOCAL_DIR="/usr/$HOST/sys-root/mingw/bin/"
        copy_system_license gcc                    "$TARGET" || return 1
        copy_system_license mingw-w64              "$TARGET" || return 1
        copy_system_license gettext                "$TARGET" || return 1
        copy_system_license iconv                  "$TARGET" || return 1
    else
        copy_system_license gcc                    "$TARGET" || return 1
        copy_system_license libudev                "$TARGET" || return 1
        copy_system_license libdb                  "$TARGET" || return 1
        copy_system_license libpcre                "$TARGET" || return 1
        copy_system_license libdirectfb            "$TARGET" || return 1
        copy_system_license libbz2                 "$TARGET" || return 1
        copy_system_license libselinux             "$TARGET" || return 1
    fi
}
