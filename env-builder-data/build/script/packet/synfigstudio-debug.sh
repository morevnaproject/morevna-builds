source "$PACKET_SCRIPT_DIR/synfigstudio-master.sh"

DEPS=`echo "$DEPS" | sed "s|synfigcore-master|synfigcore-debug|g"`
DEPS_NATIVE=`echo "$DEPS_NATIVE" | sed "s|synfigcore-master|synfigcore-debug|g"`
PK_URL="https://github.com/synfig/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="origin/debug"
PK_CONFIGURE_OPTIONS="--enable-debug --enable-optimization=0"
