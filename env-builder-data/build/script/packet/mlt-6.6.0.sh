# + ffmpeg
# + xml
# + fftw
# + samplerate
# ? sdl
# ? sox
# + jack
# + glib

DEPS="ffmpeg-3.1.5 xml-2.9.4 fftw-3.3.5 samplerate-0.1.9 sdl-1.2.15 sox-14.4.2 glib-2.50.0"

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
        PK_CONFIGURE_OPTIONS="$PK_CONFIGURE_OPTIONS --target-arch=x86_$ARCH"
    fi
fi

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

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
