# + sdl ?
# + yasm
# + lame ?
# + ogg
# + theora
# + vorbis
# + x264

DEPS="sdl-2.0.5 yasm-1.3.0 lame-3.99.5 ogg-1.3.2 theora-1.1.1 vorbis-1.3.5 x264-master"

PK_DIRNAME="ffmpeg-3.1.5"
PK_ARCHIVE="$PK_DIRNAME.tar.bz2"
PK_URL="http://ffmpeg.org/releases/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS=" \
 --enable-rpath \
 --enable-gpl \
 --enable-libx264 \
 --enable-libmp3lame \
 --enable-libtheora \
 --enable-libvorbis"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
