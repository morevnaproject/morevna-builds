source "$PACKET_SCRIPT_DIR/opentoonz-master.sh"

PK_DIRNAME="opentoonz"
PK_URL="https://github.com/morevnaproject-org/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="origin/testing"

# Bundle FFmpeg next to the OpenToonz binary (bin/ffmpeg, bin/ffprobe).
# 64-bit only: the ffmpeg dependency chain (x264, theora, vorbis, lame,
# sdl-1.2.15) was never built for 32-bit in this environment.
if [ "$ARCH" = "64" ]; then
    DEPS="$DEPS ffmpeg-3.1.5"
fi
