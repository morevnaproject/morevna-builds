# + ffmpeg
# + xml
# + fftw
# + samplerate
# ? sdl
# ? sox
# + jack
# + glib

DEPS="ffmpeg-3.1.5 xml-2.9.4 fftw-3.3.5 samplerate-0.1.9 sdl-2.0.5 jack-0.125.0 glib-2.50.0"

PK_DIRNAME="mlt-6.2.0"
PK_ARCHIVE="v6.2.0.tar.gz"
PK_URL="https://github.com/mltframework/mlt/archive/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS=" \
 --enable-gpl \
 --enable-gpl3 \
 --disable-decklink \
 --disable-gtk2 \
 --disable-opengl \
 --disable-qt \
 --disable-rtaudio"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

