# + ffmpeg
# + xml
# + fftw
# + samplerate
# ? sdl
# ? sox
# + jack
# + glib

DEPS="ffmpeg-3.1.5 xml-2.9.4 fftw-3.3.5 samplerate-0.1.9 sdl-1.2.15 sox-14.4.2 glib-2.69.3"

PK_DIRNAME="mlt-6.6.0"
PK_ARCHIVE="v6.6.0.tar.gz"
PK_URL="https://github.com/mltframework/mlt/archive/$PK_ARCHIVE"
PK_CONFIGURE_OPTIONS=" \
 --enable-gpl \
 --enable-gpl3 \
 --disable-decklink \
 --disable-gtk2 \
 --disable-opengl \
 --disable-qt \
 --disable-rtaudio"

if [ "$PLATFORM" = "linux" ]; then
    DEPS="$DEPS jack-0.125.0"
fi

if [ "$PLATFORM" = "win" ]; then
    DEPS="$DEPS dlfcnwin32-1.1.1"

    PK_CONFIGURE_OPTIONS="$PK_CONFIGURE_OPTIONS --target-os=MinGW"
    if [ "$ARCH" = "32" ]; then
        PK_CONFIGURE_OPTIONS="$PK_CONFIGURE_OPTIONS --target-arch=i686"
    else
        PK_CONFIGURE_OPTIONS="$PK_CONFIGURE_OPTIONS --target-arch=x86_64"
    fi
fi

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    
    if ! pkhook_prebuild; then
        return 1
    fi

    PK_CFLAGS="-I/usr/$HOST/include/"
    PK_CPPFLAGS="-I/usr/$HOST/include/"
    PK_LDFLAGS="-L/usr/$HOST/lib"

    if ! check_packet_function $NAME build.configure; then
        CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" LDFLAGS="$PK_LDFLAGS $LDFLAGS" \
        ./configure \
            $PK_CONFIGURE_OPTIONS_DEFAULT \
            $PK_CONFIGURE_OPTIONS \
         || return 1
        set_done $NAME build.configure
    fi
    
    if [ -z $HOST ]; then
        if [ "$ARCH" = "32" ]; then
            HOST="i686-linux-gnu"
        else
            HOST="x86_64-linux-gnu"
        fi
    fi
    
    CFLAGS="$PK_CFLAGS $CFLAGS" CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" LDFLAGS="$PK_LDFLAGS $LDFLAGS" \
     CC="$HOST-gcc" CXX="$HOST-g++" make -j${THREADS} || return 1
}

pkhook_postinstall() {
    if [ "$PLATFORM" = "win" ]; then
        mkdir -p "bin"
        mkdir -p "bin/lib"
        mkdir -p "bin/share"
        mv "libmlt++-3.dll" "bin/"
        mv "libmlt-6.dll"   "bin/"
        mv "melt"           "bin/melt.exe"
        mv "lib/mlt"        "bin/lib/"
        mv "share/mlt"      "bin/share/"
    fi
}
