DEPS="graphviz-2.40.1"

PK_DIRNAME="doxygen-1.8.8"
PK_ARCHIVE="$PK_DIRNAME.src.tar.gz"
PK_URL="https://sourceforge.net/projects/doxygen/files/rel-1.8.8/$PK_ARCHIVE/download"

PK_CONFIGURE_OPTIONS_DEFAULT="--prefix $INSTALL_PACKET_DIR"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
