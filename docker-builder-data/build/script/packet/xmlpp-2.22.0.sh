DEPS="xml-2.9.4 glibmm-2.41.4"

PK_DIRNAME="libxml++-2.22.0"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://download.gnome.org/sources/libxml++/2.22/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    if ! check_packet_function $NAME build.cunfigure; then
        CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" \
        ./configure \
         $PK_CONFIGURE_OPTIONS_DEFAULT \
         $PK_CONFIGURE_OPTIONS \
         || return 1
        set_done $NAME build.cunfigure
    fi

    if [ "$PLATFORM" = "win" ]; then
        if [ ! -f "libxml++/exceptions/exception.h.orig" ]; then
            mv libxml++/exceptions/exception.h libxml++/exceptions/exception.h.orig
        fi
        cat libxml++/exceptions/exception.h.orig | sed -e 's/LIBXMLPP_API//g' > libxml++/exceptions/exception.h
    fi

    if ! CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" \
     make -j${THREADS}; then
        return 1
    fi
}
