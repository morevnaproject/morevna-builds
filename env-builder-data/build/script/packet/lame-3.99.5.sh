DEPS=""

PK_DIRNAME="lame-3.99.5"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://sourceforge.net/projects/lame/files/lame/3.99/$PK_ARCHIVE/download"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

if [ "$ARCH" = "32" ]; then
    PK_CFLAGS="-msse"
fi