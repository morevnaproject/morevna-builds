DEPS=""

PK_DIRNAME="SDL2-2.0.5"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://www.libsdl.org/release/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS_DEFAULT="--host=$HOST --prefix=$INSTALL_PACKET_DIR"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
