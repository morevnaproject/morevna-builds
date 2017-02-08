# + sdl ?
# + yasm
# + lame ?
# + ogg
# + theora
# + vorbis
# + x264

DEPS="lame-3.99.5 ogg-1.3.2 theora-1.1.1 vorbis-1.3.5 x264-master sdl-1.2.15"
DEPS_NATIVE="yasm-1.3.0"

PK_DIRNAME="ffmpeg-3.1.5"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="http://ffmpeg.org/releases/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS_DEFAULT=" \
 --prefix=$INSTALL_PACKET_DIR \
 --disable-static \
 --enable-shared"

PK_CONFIGURE_OPTIONS="
 --disable-doc \
 --enable-rpath \
 --enable-gpl \
 --enable-libx264 \
 --enable-libmp3lame \
 --enable-libtheora \
 --enable-libvorbis"

if [ "$PLATFORM" = "win" ]; then
    PK_CONFIGURE_OPTIONS="$PK_CONFIGURE_OPTIONS \
     --arch=x86_$ARCH \
     --target-os=mingw$ARCH \
     --cross-prefix=$HOST- \
     --host-cc=$HOST-gcc \
     --host-ld=$HOST-gcc \
     --enable-cross-compile"
fi

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
