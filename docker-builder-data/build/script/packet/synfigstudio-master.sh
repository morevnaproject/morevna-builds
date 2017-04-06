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

    # copy system libraries
    if [ "$PLATFORM" = "win" ]; then
        local TARGET="$INSTALL_PACKET_DIR/bin/"
        local LOCAL_DIR="/usr/$HOST/sys-root/mingw/bin/"
        cp $LOCAL_DIR/libgcc*.dll        "$TARGET" || return 1
        cp $LOCAL_DIR/libstdc*.dll       "$TARGET" || return 1
        cp $LOCAL_DIR/libwinpthread*.dll "$TARGET" || return 1
        cp $LOCAL_DIR/libquadmath*.dll   "$TARGET" || return 1
        cp $LOCAL_DIR/libgfortran*.dll   "$TARGET" || return 1
        cp $LOCAL_DIR/iconv*.dll         "$TARGET" || return 1
        cp $LOCAL_DIR/libintl*.dll       "$TARGET" || return 1
        cp $LOCAL_DIR/libdl*.dll         "$TARGET" || return 1
        cp $LOCAL_DIR/libltdl*.dll       "$TARGET" || return 1
        cp $LOCAL_DIR/libexpat*.dll      "$TARGET" || return 1
        cp $LOCAL_DIR/zlib*.dll          "$TARGET" || return 1
        cp $LOCAL_DIR/libbz2*.dll        "$TARGET" || return 1
        cp $LOCAL_DIR/libfreetype*.dll   "$TARGET" || return 1
    else
        local TARGET="$INSTALL_PACKET_DIR/lib/"
        copy_system_lib libudev          "$TARGET" || return 1
        copy_system_lib libgfortran      "$TARGET" || return 1
        copy_system_lib libdb            "$TARGET" || return 1
        copy_system_lib libpcre          "$TARGET" || return 1
        copy_system_lib libdirect        "$TARGET" || return 1
        copy_system_lib libfusion        "$TARGET" || return 1
        copy_system_lib libbz2           "$TARGET" || return 1
    fi
}

pkhook_postlicense() {
    local TARGET="$LICENSE_PACKET_DIR"
    if [ "$PLATFORM" = "win" ]; then
        local LOCAL_DIR="/usr/$HOST/sys-root/mingw/bin/"
        copy_system_license "mingw$ARCH-gcc gcc"   "$TARGET" || return 1
        copy_system_license mingw$ARCH-winpthreads "$TARGET" || return 1
        copy_system_license mingw$ARCH-gettext     "$TARGET" || return 1
        copy_system_license mingw$ARCH-win-iconv   "$TARGET" || return 1
        copy_system_license mingw$ARCH-dlfcn       "$TARGET" || return 1
        copy_system_license mingw$ARCH-libltdl     "$TARGET" || return 1
        copy_system_license mingw$ARCH-expat       "$TARGET" || return 1
        copy_system_license mingw$ARCH-bzip2       "$TARGET" || return 1
        copy_system_license mingw$ARCH-freetype    "$TARGET" || return 1
    else
        copy_system_license libudev                "$TARGET" || return 1
        copy_system_license gfortran               "$TARGET" || return 1
        copy_system_license libdb                  "$TARGET" || return 1
        copy_system_license libpcre                "$TARGET" || return 1
        copy_system_license libdirectfb            "$TARGET" || return 1
        copy_system_license libfusion              "$TARGET" || return 1
        copy_system_license libbz2                 "$TARGET" || return 1
    fi
}
