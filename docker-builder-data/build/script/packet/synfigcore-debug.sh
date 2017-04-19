source "$PACKET_SCRIPT_DIR/synfigcore-master.sh"

DEPS=`echo "$DEPS" | sed "s|synfigetl-master|synfigetl-debug|g"`
PK_URL="https://github.com/blackwarthog/$PK_DIRNAME.git"
PK_GIT_OPTIONS="--branch debug"
PK_CPPFLAGS="-Wa,-mbig-obj"
PK_CONFIGURE_OPTIONS="--enable-debug --enable-optimization=0"
