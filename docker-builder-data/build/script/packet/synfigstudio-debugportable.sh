source "$PACKET_SCRIPT_DIR/synfigstudio-portable.sh"
DEPS=`echo "$DEPS" | sed "s|synfigstudio-master|synfigstudio-debug|g"`
