DEPS="ffmpeg-3.1.5 xml-2.9.4 fftw-3.3.5 samplerate-0.1.9 sdl-1.2.15 sox-14.4.2 glib-2.50.0"

PK_DIRNAME="mlt-0.9.6"
PK_ARCHIVE="v0.9.6.tar.gz"
PK_URL="https://github.com/mltframework/mlt/archive/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS=" \
 --enable-gpl \
 --disable-decklink \
 --disable-gtk2 \
 --disable-opengl \
 --disable-qt"

if [ "$PLATFORM" = "win" ]; then
    DEPS="$DEPS jack-0.125.0"
fi

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

