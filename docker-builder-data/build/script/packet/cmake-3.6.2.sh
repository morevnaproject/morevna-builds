DEPS=""

PK_DIRNAME="cmake-3.6.2"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://cmake.org/files/v3.6/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS_DEFAULT="--host=$HOST --prefix=$INSTALL_PACKET_DIR"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
