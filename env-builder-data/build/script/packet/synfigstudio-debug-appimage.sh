source "$PACKET_SCRIPT_DIR/synfigstudio-master-appimage.sh"

DEPS=`echo "$DEPS" | sed "s|synfigstudio-master|synfigstudio-debug|g"`
PK_URL="https://github.com/blackwarthog/synfig.git"
PK_GIT_CHECKOUT="origin/debug"
