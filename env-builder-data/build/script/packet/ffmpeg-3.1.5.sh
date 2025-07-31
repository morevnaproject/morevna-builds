# + sdl ?
# + yasm
# + lame ?
# + ogg
# + theora
# + vorbis
# + x264
# + vpx

DEPS="lame-3.99.5 ogg-1.3.2 theora-1.1.1 vorbis-1.3.5 x264-master sdl-1.2.15 vpx-1.6.1"
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
 --enable-libvorbis \
 --enable-libopus \
 --enable-libvpx"

if [ "$PLATFORM" = "win" ]; then
    PK_CONFIGURE_OPTIONS="$PK_CONFIGURE_OPTIONS \
     --arch=x86_$ARCH \
     --target-os=mingw$ARCH \
     --cross-prefix=$HOST- \
     --host-cc=$HOST-gcc \
     --host-ld=$HOST-gcc \
     --enable-cross-compile"
fi

PK_LICENSE_FILES="CREDITS LICENSE.md COPYING.GPLv2 COPYING.GPLv3 COPYING.LGPLv2.1 COPYING.LGPLv3"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
